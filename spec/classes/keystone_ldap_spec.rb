require 'spec_helper'

describe 'keystone::ldap' do

  describe 'with default params' do

    it 'should contain default params' do

      should contain_keystone_config('ldap/url').with_value('ldap://localhost')
      should contain_keystone_config('ldap/user').with_value('dc=Manager,dc=example,dc=com')
      should contain_keystone_config('ldap/password').with_value('None')
      should contain_keystone_config('ldap/suffix').with_value('cn=example,cn=com')
      should contain_keystone_config('ldap/user_tree_dn').with_value('ou=Users,dc=example,dc=com')
      should contain_keystone_config('ldap/tenant_tree_dn').with_value('ou=Roles,dc=example,dc=com')
      should contain_keystone_config('ldap/role_tree_dn').with_value('dc=example,dc=com')
      should contain_keystone_config('ldap/user_filter').with_value('')
      should contain_keystone_config('ldap/user_objectclass').with_value('inetOrgPerson')
      should contain_keystone_config('ldap/user_id_attribute').with_value('cn')
      should contain_keystone_config('ldap/user_name_attribute').with_value('sn')
      should contain_keystone_config('ldap/user_mail_attribute').with_value('email')
      should contain_keystone_config('ldap/user_allow_create').with_value('True')
      should contain_keystone_config('ldap/user_allow_update').with_value('True')
      should contain_keystone_config('ldap/user_allow_delete').with_value('True')
      should contain_keystone_config('ldap/user_pass_attribute').with_value('userPassword')
      should contain_keystone_config('ldap/user_enabled_emulation').with_value('False')
      should contain_keystone_config('ldap/user_enabled_emulation_dn').with_value('cn=enabled_users,dc=example,dc=com')
      should contain_keystone_config('ldap/group_tree_dn').with_value('ou=Groups,dc=example,dc=com')
      should contain_keystone_config('ldap/group_filter').with_value('')
      should contain_keystone_config('ldap/group_objectclass').with_value('groupOfNames')
      should contain_keystone_config('ldap/group_id_attribute').with_value('cn')
      should contain_keystone_config('ldap/group_name_attribute').with_value('ou')
      should contain_keystone_config('ldap/group_member_attribute').with_value('member')
      should contain_keystone_config('ldap/group_desc_attribute').with_value('desc')
      should contain_keystone_config('ldap/group_allow_create').with_value('True')
      should contain_keystone_config('ldap/group_allow_update').with_value('True')
      should contain_keystone_config('ldap/group_allow_delete').with_value('True')
      should contain_keystone_config('ldap/use_tls').with_value('False')
      should contain_keystone_config('ldap/tls_cacertfile').with_value('')
      should contain_keystone_config('ldap/tls_req_cert').with_value('demand')
      should contain_keystone_config('identity/driver').with_value('keystone.identity.backends.ldap.Identity')
      should contain_keystone_config('assignment/driver').with_value('keystone.identity.backends.sql.Assignment')
    end

  end

end
