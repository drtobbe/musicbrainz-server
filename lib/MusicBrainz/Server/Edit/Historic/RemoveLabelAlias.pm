package MusicBrainz::Server::Edit::Historic::RemoveLabelAlias;
use strict;
use warnings;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LABEL_ALIAS );
use MusicBrainz::Server::Translation qw ( l ln );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name { l('Remove label alias') }
sub historic_type { 62 }
sub edit_type { $EDIT_HISTORIC_REMOVE_LABEL_ALIAS }
sub edit_template { 'historic/remove_label_alias' }

sub related_entities {
    my $self = shift;
    return { }
}

sub build_display_data
{
    my $self = shift;
    return {
        alias => $self->data->{alias}
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        alias => $self->previous_value,
        alias_id => $self->row_id
    });

    return $self;
}

sub deserialize_new_value {
    my ($self, $value ) = @_;
    return $value;
}

sub deserialize_previous_value {
    my ($self, $value ) = @_;
    return $value;
}

1;
