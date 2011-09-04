
use strict;
use warnings;

use lib 't/tlib';

use Test::More;
use Test::TCP;
use Test::Statim::Runner;

use Statim;
use Statim::Client;

test_tcp(
    server => sub {
        my $port = shift;
        my $app  = test_statim_server($port);
        $app->run;
    },

    client => sub {
        my $port = shift;

        require StatimTest::Schema::Log;

        StatimTest::Schema::Log->load_components(qw(Statim));

        StatimTest::Schema::Log->statim_host('127.0.0.1');
        StatimTest::Schema::Log->statim_port($port);
        StatimTest::Schema::Log->statim_collection('log');
        StatimTest::Schema::Log->statim_enum_cols( 'customer_id', 'status' );
        StatimTest::Schema::Log->statim_count_col('entry');

        use StatimTest::Schema;

        my $schema = StatimTest::Schema->connect();
        my $log    = $schema->resultset('Log');

        {
            $log->create(
                {
                    customer_id => 1,
                    status      => 'OK',
                }
            );

        }

        {
            $log->create(
                {
                    customer_id => 1,
                    status      => 'OK'
                }
            );
        }

        my $statim = Statim::Client->new(
            {
                host => '127.0.0.1',
                port => $port
            }
        );

        {
            my $ret = $statim->get( 'log', 'customer_id:1', 'status:OK', 'entry' );
            is $ret, "OK 2\r\n";
        }
    }
);

done_testing();

