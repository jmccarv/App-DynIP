use strict;
use warnings;

use DynIP;

my $app = DynIP->apply_default_middlewares(DynIP->psgi_app);
$app;

