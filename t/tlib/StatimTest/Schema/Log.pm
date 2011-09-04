
package StatimTest::Schema::Log;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw(
    PK::Auto
    Core
));

__PACKAGE__->table('log');

__PACKAGE__->add_columns(
    id => { is_auto_increment => 1 },
    qw/
        customer_id
        status
    /
);

__PACKAGE__->set_primary_key( 'id' );

1;
