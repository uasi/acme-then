use inc::Module::Install;

name 'Acme-Then';
all_from 'lib/Acme/Then.pm';

requires 'parent';

test_requires 'AE';
test_requires 'Test::More';

WriteAll;
