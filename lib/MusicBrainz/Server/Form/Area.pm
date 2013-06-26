package MusicBrainz::Server::Form::Area;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-area' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'sort_name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'iso_3166_1' => (
    type => 'Repeatable',
);

has_field 'iso_3166_1.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISO_3166_1',
);

has_field 'iso_3166_2' => (
    type => 'Repeatable',
);

has_field 'iso_3166_2.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISO_3166_2',
);

has_field 'iso_3166_3' => (
    type => 'Repeatable',
);

has_field 'iso_3166_3.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISO_3166_3',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

sub edit_field_names
{
    return qw( name sort_name type_id period.begin_date period.end_date period.ended iso_3166_1 iso_3166_2 iso_3166_3 );
}

sub options_type_id     { shift->_select_all('AreaType') }

sub dupe_model { shift->ctx->model('Area') }

sub validate {
    my ($self) = @_;

    return 1;
}

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
