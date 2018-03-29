#!/usr/bin/env perl

Script->new({ files => \@ARGV })->run;
exit;

package Script;

use strict;
use warnings;

use File::Spec;
use Data::Debug;
use List::Util qw(reduce);

sub new {
    my $class = shift;
    my $hash = shift || { files => [] };

    $hash->{'file_labels'} = {
        'http_server_summary.txt' => 'HTTP',
        'https_server_summary.txt' => 'HTTPS',
        'socket_server_summary.txt' => 'Socket',
        'pm2_http_server_summary.txt' => 'HTTP/PM2',
        'pm2_https_server_summary.txt' => 'HTTPS/PM2',
        'pm2_socket_server_summary.txt' => 'Socket/PM2',
        'http_cluster_server_summary.txt' => 'HTTP/Cluster',
        'https_cluster_server_summary.txt' => 'HTTPS/Cluster',
        'socket_cluster_server_summary.txt' => 'Socket/Cluster',
    };

    $hash->{'first_col_width'} = length reduce { length($a) > length($b) ? $a : $b } values %{$hash->{'file_labels'}};

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

    my $cell_spacing = 8;

    my $second_col_width = length reduce { length($a) > length($b) ? $a : $b }
                                     map { $report->{$_}{'RPS'} }
                                    keys %$report;

    for my $label ( sort keys %$report ) {
        my $first_col_spacing_length  = $self->{'first_col_width'} - length($label);
        my $second_col_spacing_length = $second_col_width - length($report->{$label}{'RPS'});

        print $label, " " x $first_col_spacing_length, " " x ($cell_spacing + $second_col_spacing_length), $report->{$label}{'RPS'}, " RPS", "\n";
    }
}

1;

