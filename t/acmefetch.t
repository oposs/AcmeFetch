#!/usr/bin/env perl
# Runs bin/acmefetch with the modules bundled in thirdparty/ and checks what
# it does without contacting an ACME server: the command line, the
# configuration check and --checkonly on certificates that exist.
use strict;
use warnings;
use FindBin;
use File::Temp qw(tempdir);
use Test::More;

my $top = "$FindBin::Bin/..";
my $script = "$top/bin/acmefetch";
my @perl = ($^X, "-I$top/thirdparty/lib/perl5");

# Runs acmefetch with the given arguments; returns exit status and output.
sub run {
    my @args = @_;
    my $pid = open my $fh, '-|';
    die "fork: $!" unless defined $pid;
    if (not $pid) {
        open STDERR, '>&', \*STDOUT or die "dup: $!";
        exec @perl, $script, @args or die "exec: $!";
    }
    my $out = join '', <$fh>;
    close $fh;
    return ($? >> 8, $out);
}

sub write_file {
    my ($file, $text) = @_;
    open my $fh, '>', $file or die "$file: $!";
    print $fh $text;
    close $fh;
}

my ($status, $out) = run('--version');
is $status, 0, '--version exits 0';
like $out, qr/^acmefetch \S+$/m, '--version names the program';

($status, $out) = run('--help');
like $out, qr/--checkonly/, '--help lists the options';

my $dir = tempdir(CLEANUP => 1);

# A certificate for the configured names, valid for 90 days, and an account
# key with an id, so --checkonly needs no ACME server.
my $openssl = 'openssl';
system($openssl, qw(req -x509 -nodes -newkey rsa:2048 -days 90 -subj /CN=a.example),
    '-addext', 'subjectAltName=DNS:a.example,DNS:b.example',
    -keyout => "$dir/a.key", -out => "$dir/a.pem") == 0
    or BAIL_OUT('openssl could not make a test certificate');
system($openssl, 'genrsa', -out => "$dir/account.key", 2048) == 0
    or BAIL_OUT('openssl could not make an account key');
write_file("$dir/account.key.id", 'https://acme.invalid/acct/1');

sub config {
    my ($common, $cert, @sites) = @_;
    my $sites = join ",\n", map {
        qq{"$_": { "challengeConfig": { "www_root": "$dir" } }}
    } @sites;
    return <<"CFG";
{
    "GENERAL": { "accountKeyPath": "$dir/account.key" },
    "CERTS": [
        {
            "certOutput": "$cert",
            "keyOutput": "$dir/a.key",
            "commonName": "$common",
            "SITES": { $sites }
        }
    ]
}
CFG
}

write_file("$dir/ok.cfg", config('a.example', "$dir/a.pem", 'a.example', 'b.example'));
($status, $out) = run("--cfg=$dir/ok.cfg", '--checkonly', '--verbose');
is $status, 0, '--checkonly on a current certificate exits 0';
like $out, qr/Cert still ok/, 'a current certificate is reported as ok';

write_file("$dir/missing.cfg", config('a.example', "$dir/none.pem", 'a.example'));
($status, $out) = run("--cfg=$dir/missing.cfg", '--checkonly');
is $status, 0, '--checkonly on a missing certificate exits 0';
like $out, qr/Cert \Q$dir\E\/none\.pem is missing/, 'a missing certificate is reported';

write_file("$dir/extra.cfg", config('a.example', "$dir/a.pem", 'a.example', 'c.example'));
($status, $out) = run("--cfg=$dir/extra.cfg", '--checkonly');
like $out, qr/missing domain c\.example/, 'a name the certificate lacks is reported';

write_file("$dir/bad.cfg", config('x.example', "$dir/a.pem", 'a.example'));
($status, $out) = run("--cfg=$dir/bad.cfg", '--checkonly');
isnt $status, 0, 'a commonName without a site fails';
like $out, qr/commonName \(x\.example\) has no matching site entry/, 'and says why';

done_testing;
