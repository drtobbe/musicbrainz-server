package MusicBrainz::Server::Report::DuplicateRelationshipsReleaseGroups;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseGroupReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID';

sub query {
    "

SELECT q.entity AS release_group_id, row_number() OVER (ORDER BY musicbrainz_collate(release_name.name)) FROM (

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_artist_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_label_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1
    
    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_recording_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_group_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_group_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION

    SELECT link.link_type, lxx.entity0, lxx.entity1 AS entity
    FROM l_release_release_group lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION
    
    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_group_work lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

    UNION
    
    SELECT link.link_type, lxx.entity1, lxx.entity0 AS entity
    FROM l_release_group_url lxx
    JOIN link ON link.id = lxx.link
    GROUP BY link.link_type, lxx.entity0, lxx.entity1 HAVING COUNT(*) > 1

) AS q
JOIN release_group on q.entity = release_group.id
JOIN release_name on release_name.id = release_group.name
GROUP BY q.entity, release_name.name

    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
;

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
