package t::MusicBrainz::Server::Data::Track;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::Track;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+tracklist');
$test->c->sql->do('UPDATE release SET edits_pending = 2 WHERE id = 2');

my $track_data = MusicBrainz::Server::Data::Track->new(c => $test->c);

my $track = $track_data->get_by_id(1);
is ( $track->id, 1 );
is ( $track->name, "King of the Mountain", "Track with row id 1 has expected name");
is ( $track->recording_id, 1 );
is ( $track->artist_credit_id, 1 );
is ( $track->position, 1, "Track with row id 1 has position 1");

$track = $track_data->get_by_id(3);
is ( $track->id, 3 );
is ( $track->name, "Bertie", "Track with row id 3 has expected name");
is ( $track->recording_id, 3 );
is ( $track->artist_credit_id, 1 );
is ( $track->position, 3, "Track with row id 3 has position 3" );

ok( !$track_data->load() );

my ($tracks, $hits) = $track_data->find_by_recording(1, 10, 0);
is( $hits, 2 );
is( scalar(@$tracks), 2 );
is( $tracks->[0]->id, 1, "Find by recording finds track with row id 1");
is( $tracks->[0]->position, 1 );
is( $tracks->[0]->medium->track_count, 7 );
is( $tracks->[0]->medium->id, 1 );
is( $tracks->[0]->medium->name, "A Sea of Honey" );
is( $tracks->[0]->medium->position, 1 );
is( $tracks->[0]->medium->release->id, 1 );
is( $tracks->[0]->medium->release->name, "Aerial" );
is( $tracks->[1]->id, 17, "Find by recording finds track with row id 17" );
is( $tracks->[1]->position, 1 );
is( $tracks->[1]->medium->track_count, 7 );
is( $tracks->[1]->medium->id, 3 );
is( $tracks->[1]->medium->name, "A Sea of Honey" );
is( $tracks->[1]->medium->position, 1 );
is( $tracks->[1]->medium->release->id, 2 );
is( $tracks->[1]->medium->release->edits_pending, 2 );
is( $tracks->[1]->medium->release->name, "Aerial" );

my %names = $track_data->find_or_insert_names('Nocturn', 'Traits');
is(keys %names, 2);
is($names{'Nocturn'}, 15);
ok($names{'Traits'} > 16);

$track = $track_data->insert({
    medium_id => 1,
    recording_id => 2,
    name => 'Test track!',
    artist_credit => 1,
    length => 500,
    position => 8,
    number => 8
});


ok(defined $track, "Track instance returned by insert");
ok($track->id > 0);

$track = $track_data->get_by_id($track->id);
is($track->position, 8);
is($track->medium_id, 1);
is($track->artist_credit_id, 1);
is($track->recording_id, 2);
is($track->length, 500);
is($track->name, "Test track!");

Sql::run_in_transaction(sub {
    my $toc = $test->c->sql->select_single_value ("SELECT toc FROM medium_index WHERE medium = 1");
    is ($toc, undef, 'medium_index does not have an entry for medium 1');

    $track_data->delete(1);
    $track = $track_data->get_by_id(1);
    ok(!defined $track);

    my $toc = $test->c->sql->select_single_value ("SELECT toc FROM medium_index WHERE medium = 1");
    is ($toc, '(628519, 358960, 332613, 296160, 372386, 500)', 'DurationLookup updated medium_index after track delete');

}, $test->c->sql);

};

1;
