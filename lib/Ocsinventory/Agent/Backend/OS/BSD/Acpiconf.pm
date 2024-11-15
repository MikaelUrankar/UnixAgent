package Ocsinventory::Agent::Backend::OS::BSD::Acpiconf;

use POSIX;
use strict;
use warnings;
use Data::Dumper;
use English qw( -no_match_vars ) ;

sub check {
    my $params = shift;
    my $common = $params->{common};

    return unless $common->can_run("acpiconf");
}

sub run {

    my $params = shift;
    my $common = $params->{common};

    my $battery;
    my $index=0;

    my @bat = `acpiconf -i $index`;

    my $data = {};
    foreach my $line (@bat) {
	if ($line =~ /^\s(.*):\s*(\S+(?:\s+\S+)*)$/) {
	    $data->{$1}=$2;
        }
    }	

    $battery = {
        NAME            => $data->{'Model number'},
        CHEMISTRY       => $data->{'Type'},
        SERIALNUMBER    => $data->{'Serial number'},
    };

    if ($battery->{CHEMISTRY} eq "LION") { 
        $battery->{CHEMISTRY} = "Lithium-Ion";
    } elsif (($battery->{CHEMISTRY} eq "LiP") || ($battery->{CHEMISTRY} eq "LiPo")) { 
         $battery->{CHEMISTRY} = "Lithium-ion-Polymer";
    }

    my $cycles = $data->{'Cycle Count'};
    $battery->{CYCLES} = $cycles if $cycles;

    my $voltage  = $data->{'Design voltage'};
    $battery->{DESIGNVOLTAGE} = ceil($voltage/1000)." V" if $voltage;

    my $capacity = $data->{'Design capacity'};
    $battery->{DESIGNCAPACITY} = $capacity if $capacity;

    my $state = $data->{'State'};
    $battery->{STATUS} = $state if $state;

    my $estimate = $data->{'Remaining capacity'};
    $battery->{ESTIMATEDCHARGEREMAINING} = $estimate if $estimate;

    my $manufacturer = $data->{'OEM info'};
    $battery->{MANUFACTURER} = $manufacturer if $manufacturer;

    $common->addBatteries($battery);

}

1;
