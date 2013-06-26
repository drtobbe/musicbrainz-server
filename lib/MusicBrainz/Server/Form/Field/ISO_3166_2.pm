package MusicBrainz::Server::Form::Field::ISO_3166_2;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_iso_3166_2 );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_iso_3166_2(shift) },
        message => l('This is not a valid ISO 3166-2 code'),
    }
]);

1;
