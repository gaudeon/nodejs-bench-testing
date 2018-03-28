#!/usr/bin/env perl

Script->new({ files => \@ARGV })->run;
exit;

package Script;

use strict;
use warnings;

use File::Spec;
use Data::Debug;

sub new {
    my $class = shift;
    my $hash = shift || { files => [] };
debug $hash->{'files'};
    $hash->{'file_labels'} = {
        'http_server_summary.txt' => 'HTTP',
        'https_server_summary.txt' => 'HTTPS',
        'socket_server_summary.txt' => 'Socket',
        'pm2_http_server_summary.txt' => 'HTTP/PM2',
        'pm2_socket_server_summary.txt' => 'Socket/PM2',
        'http_cluster_server_summary.txt' => 'HTTP/Cluster',
        'socket_cluster_server_summary.txt' => 'Socket/Cluster',
    };

    $hash->{'file_path_map'} = { map { $_ => (File::Spec->splitpath( $_ ))[2] } @{$hash->{'files'}} };

    return bless $hash, $class;
}

sub run {
    my $self = shift;

    my %report;

    for my $file (@{$self->{'files'}}) {
        my $filename = $self->{'file_path_map'}{$file};
        my $label    = $self->{'file_labels'}{ $filename };

        next unless $label; # If we don't have a label it's not a file we are looking for

        open(my $fh, '<', $file) || next;
        my $contents = join '', <$fh>;
        close $fh;

        next unless $contents;

        # Requests per second
        $report{$label}{'RPS'} = $1 if $contents =~ m/^Requests per second:\s+([0-9\.]+)\b/mg;
    }

    $self->print(\%report);
}

sub print {
    my ($self, $report) = @_;

    for my $label ( sort keys %$report ) {
        print $label, "\t"x2, $report->{$label}{'RPS'}, " RPS", "\n";
    }
}

1;

