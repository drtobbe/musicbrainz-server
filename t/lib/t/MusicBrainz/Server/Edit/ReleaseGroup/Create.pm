package t::MusicBrainz::Server::Edit::ReleaseGroup::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Create }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_CREATE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_database($c, '+releasegrouptype');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE release_group CASCADE;
SQL

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Create');

ok(defined $edit->release_group_id);

my ($edits, $hits) = $c->model('Edit')->find({ release_group => $edit->release_group_id }, 10, 0);
is($edits->[0]->id, $edit->id);

my $rg = $c->model('ReleaseGroup')->get_by_id($edit->release_group_id);
$c->model('ArtistCredit')->load($rg);
ok(defined $rg);
is($rg->name, 'Empty Release Group');
is($rg->comment => 'An empty release group!');
is($rg->artist_credit->names->[0]->name, 'Foo Foo');
is($rg->artist_credit->names->[0]->artist_id, 1);
is($rg->type_id, 1);
is($rg->edits_pending, 1);

reject_edit($c, $edit);

$rg = $c->model('ReleaseGroup')->get_by_id($edit->release_group_id);
ok(!defined $rg);

$edit = create_edit($c);
accept_edit($c, $edit);

$rg = $c->model('ReleaseGroup')->get_by_id($edit->release_group_id);
ok(defined $rg);
is($rg->edits_pending, 0);

};

sub create_edit
{
    my $c = shift;
    return $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_RELEASEGROUP_CREATE,
        name => 'Empty Release Group',
        artist_credit => [
        { artist => 1, name => 'Foo Foo' }
        ],
        comment => 'An empty release group!',
        type_id => 1
    );
}

1;
