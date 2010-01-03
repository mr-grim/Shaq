package Sample::Schema::Result::Roles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
  "RandomStringColumns",
  "InflateColumn::DateTime",
  "TimeStamp",
  "DigestColumns::Lite",
  "UTF8Columns",
  "Core",
);
__PACKAGE__->table("roles");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "name",
  {
    data_type => "STRING",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "user_roles",
  "Sample::Schema::Result::UserRoles",
  { "foreign.role_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-12-02 21:12:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sbF3cjpvM8xKQqC9WvgBiA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
