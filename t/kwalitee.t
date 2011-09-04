#!/usr/bin/perl
use strictures 1;
use autodie;
use Test::Most;

eval { require Test::Kwalitee; Test::Kwalitee->import() };

plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;
