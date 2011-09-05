
package DBIx::Class::Statim;

use strict;
use warnings;

use base qw( DBIx::Class );
use Statim::Client;

# ABSTRACT: Convenient way to use Statim with DBIx::Class.
# VERSION

=head1 NAME

DBIx::Class::Statim - Convenient way to use Statim with DBIx::Class.

=head1 SYNOPSIS

   package StatimTest::Schema::Log;

   use strict;
   use warnings;

   use base qw( DBIx::Class );

   __PACKAGE__->load_components(qw(PK::Auto Core ));
   __PACKAGE__->table('log');

    __PACKAGE__->add_columns(
        id => { is_auto_increment => 1 },
        qw/customer_id status/
    );

    __PACKAGE__->set_primary_key( 'id' );

    __PACKAGE__->statim_host('127.0.0.1');
    __PACKAGE__->statim_port('54130');
    __PACKAGE__->statim_collection('log');
    __PACKAGE__->statim_enum_cols('customer_id', 'status' );
    __PACKAGE__->statim_count_col('entry');

    1;


=head1 GETTING HELP/SUPPORT

The community can be found via:

=over

=item * IRC: irc.perl.org#sao-paulo.pm

=item * Github: L<http://github.com/maluco/DBIx-Class-Statim>

=back

=cut

__PACKAGE__->mk_classdata( 'statim_host' => '127.0.0.1' );
__PACKAGE__->mk_classdata( 'statim_port' => 0 );
__PACKAGE__->mk_classdata( 'statim_collection' => 'collection' );

sub new {
    my $class = shift;
    my $data = shift;

    my @args;
    map {
        push( @args, join(':', $_, $data->{$_}) );
    } grep { ! /-result_source/ } keys %$data;
    my $ret = $class->next::method($data, @_);
    $class->update_statim(@args);
    return $ret;
}

__PACKAGE__->mk_classdata( '_enum_cols'  => () );

sub statim_enum_cols {
    my $class = shift;
    if (@_) {
        $class->_enum_cols( @_ );
    }
    return $class->_enum_cols;
}

__PACKAGE__->mk_classdata( '_count_col'  => '' );

sub statim_count_col {
    my $class = shift;
    if (@_) {
        my $col = shift;
        $class->_count_col($col);
    }
    return $class->_count_col;
}

sub update_statim {
    my $class = shift;
    my @args = @_;

    my $statim = Statim::Client->new({
        host => $class->statim_host,
        port => $class->statim_port
    });

    $statim->add( $class->statim_collection,
        @args,
        join( ':', $class->_count_col, 1) );

}

1;
