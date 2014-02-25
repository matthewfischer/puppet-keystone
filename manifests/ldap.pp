#
# Implements ldap configuration for keystone.
#
# == Dependencies
# == Examples
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone::ldap(
  $url                       = 'ldap://localhost',
  $user                      = 'dc=Manager,dc=example,dc=com',
  $password                  = 'None',
  $suffix                    = 'cn=example,cn=com',
  $user_tree_dn              = 'ou=Users,dc=example,dc=com',
  $user_filter               = '',
  $user_objectclass          = 'inetOrgPerson',
  $user_id_attribute         = 'cn',
  $user_name_attribute       = 'sn',
  $user_mail_attribute       = 'email',
  $user_allow_create         = 'True',
  $user_allow_update         = 'True',
  $user_allow_delete         = 'True',
  $user_pass_attribute       = 'userPassword',
  $user_enabled_emulation    = 'False',
  $user_enabled_emulation_dn = 'cn=enabled_users,dc=example,dc=com',
  $group_tree_dn             = 'ou=Groups,dc=example,dc=com',
  $group_filter              = '',
  $group_objectclass         = 'groupOfNames',
  $group_id_attribute        = 'cn',
  $group_name_attribute      = 'ou',
  $group_member_attribute    = 'member',
  $group_desc_attribute      = 'description',
  $group_allow_create        = 'True',
  $group_allow_update        = 'True',
  $group_allow_delete        = 'True',
  $tenant_tree_dn            = 'ou=Roles,dc=example,dc=com',
  $role_tree_dn              = 'dc=example,dc=com',
  $use_tls                   = 'False',
  $tls_cacertfile            = '',
  $tls_req_cert              = 'demand',
  # default to use LDAP for Identity and Keystone's SQL backend for Assignment
  $identity_driver           = 'keystone.identity.backends.ldap.Identity',
  $assignment_driver         = 'keystone.assignment.backends.sql.Assignment'
) {

  package { [
      'python-ldap'
    ]:
      ensure => latest,
  }

  keystone_config {
    'ldap/url':                       value => $url;
    'ldap/user':                      value => $user;
    'ldap/password':                  value => $password;
    'ldap/suffix':                    value => $suffix;
    'ldap/user_tree_dn':              value => $user_tree_dn;
    'ldap/tenant_tree_dn':            value => $tenant_tree_dn;
    'ldap/role_tree_dn':              value => $role_tree_dn;
    'ldap/user_filter':               value => $user_filter;
    'ldap/user_objectclass':          value => $user_objectclass;
    'ldap/user_id_attribute':         value => $user_id_attribute;
    'ldap/user_name_attribute':       value => $user_name_attribute;
    'ldap/user_mail_attribute':       value => $user_mail_attribute;
    'ldap/user_allow_create':         value => $user_allow_create;
    'ldap/user_allow_update':         value => $user_allow_update;
    'ldap/user_allow_delete':         value => $user_allow_delete;
    'ldap/user_pass_attribute':       value => $user_pass_attribute;
    'ldap/user_enabled_emulation':    value => $user_enabled_emulation;
    'ldap/user_enabled_emulation_dn': value => $user_enabled_emulation_dn;
    'ldap/group_tree_dn':             value => $group_tree_dn;
    'ldap/group_filter':              value => $group_filter;
    'ldap/group_objectclass':         value => $group_objectclass;
    'ldap/group_id_attribute':        value => $group_id_attribute;
    'ldap/group_member_attribute':    value => $group_member_attribute;
    'ldap/group_allow_create':        value => $group_allow_create;
    'ldap/group_allow_update':        value => $group_allow_update;
    'ldap/group_allow_delete':        value => $group_allow_delete;
    'idenity/driver':                 value => $identity_driver;
    'assignment/driver':              value => $assignment_driver;
  }
}
