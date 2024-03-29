requires 'List::Util';
requires 'Mojo::Base';
requires 'Mojo::File';
requires 'Mojo::Loader';
requires 'Mojo::Log';
requires 'Mojo::URL';
requires 'Mojo::UserAgent';
requires 'Safe::Isa';
requires 'Syntax::Keyword::Try';
requires 'YAML';
requires 'namespace::autoclean';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
    requires 'perl', '5.008_001';
};

on test => sub {
    requires 'DDP';
    requires 'Test::More', '0.98';
    requires 'perl', '5.028';
    requires 'strictures', '2';
};
