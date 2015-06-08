use strict;
use warnings;

use App::DynIP;

my $app = App::DynIP->apply_default_middlewares(App::DynIP->psgi_app);
$app;

