package t::MusicBrainz::Server::Edit::Release::Merge;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::Merge };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE );
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    { id => 2, old_position => 1, new_position => 1 }
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    { id => 3, old_position => 1, new_position => 2 }
                ]
            }
        ]
    );

    ok($c->model('Release')->get_by_id(6));
    ok($c->model('Release')->get_by_id(7));

    $edit = $c->model('Edit')->get_by_id($edit->id);
    accept_edit($c, $edit);

    ok($c->model('Release')->get_by_id(6));
    ok(!$c->model('Release')->get_by_id(7));

    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 8,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    { id => 2, old_position => 1, new_position => 1 },
                    { id => 3, old_position => 2, new_position => 2 }
                ]
            },
            {
                release => {
                    id => 8,
                    name => 'Release 2',
                },
                mediums => [
                    { id => 4, old_position => 1, new_position => 3 }
                ]
            }
        ]
    );

    accept_edit($c, $edit);
};

test 'Linking Merge Release edits to recordings' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );

    # Use a set because the order can be different, but the elements should be the same.
    use Set::Scalar;
    is(Set::Scalar->new(2, 3)->compare(Set::Scalar->new(@{ $edit->related_entities->{recording} })), 'equal', "Related recordings are correct");

    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity => {
            id => 6,
            name => 'Release 1',
        },
        old_entities => [
            {
                id => 7,
                name => 'Release 2'
            }
        ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_APPEND,
        medium_changes => [
            {
                release => {
                    id => 6,
                    name => 'Release 1',
                },
                mediums => [
                    { id => 2, old_position => 1, new_position => 1 }
                ]
            },
            {
                release => {
                    id => 7,
                    name => 'Release 2',
                },
                mediums => [
                    { id => 3, old_position => 1, new_position => 2 }
                ]
            }
        ]
    );

    is_deeply([], $edit->related_entities->{recording}, 'empty related recordings for MERGE_APPEND');
};

test 'Old medium and tracks are removed during merge' => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+release');

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_MERGE,
        editor_id => 1,
        new_entity =>     { id => 6, name => 'Release 1' },
        old_entities => [ { id => 7, name => 'Release 2' } ],
        merge_strategy => $MusicBrainz::Server::Data::Release::MERGE_MERGE
    );

    $edit->accept ();

    my $release = $c->model('Release')->get_by_gid ('7a906020-72db-11de-8a39-0800200c9a71');
    $c->model('Medium')->load_for_releases ($release);
    $c->model('Track')->load_for_mediums($release->all_mediums);

    is ($release->name, "The Prologue (disc 1)", "Release has expected name after merge");
    is ($release->combined_track_count, 1, "Release has 1 track");
    is ($release->mediums->[0]->tracks->[0]->gid, 'd6de1f70-4a29-4cce-a35b-aa2b56265583', "Track has expected mbid");

    my $medium = $c->model('Medium')->get_by_id (3);
    is ($medium, undef, "Old medium no longer exists");

    # FIXME: this should probably redirect to d6de1f70-4a29-4cce-a35b-aa2b56265583.
    my $track = $c->model('Track')->get_by_gid ('929e5fb9-cfe7-4764-b3f6-80e056f0c1da');
    is ($track, undef, "Old track no longer exists");
};

1;
