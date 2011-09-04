
package DBIx::Class::Statim;

use strict;
use warnings;

use base qw( DBIx::Class );
use Statim::Client;

our $VERSION = '0.0001';

__PACKAGE__->mk_classdata( 'statim_host' => '127.0.0.1' );
__PACKAGE__->mk_classdata( 'statim_port' => 0 );
__PACKAGE__->mk_classdata( 'statim_collection' => 'collection' );
__PACKAGE__->mk_classdata( '_enum_cols'  => () );
__PACKAGE__->mk_classdata( '_count_col'  => '' );

sub statim_enum_cols {
    my $class = shift;
    if (@_) {
        $class->_enum_cols( @_ );
    }
    return $class->_enum_cols;
}

sub statim_count_col {
    my $class = shift;
    if (@_) {
        my $col = shift;
        $class->_count_col($col);
    }
    return $class->_count_col;
}

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

