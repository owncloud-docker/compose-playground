#!/usr/bin/env bash
set -x

CONFIG=$(cat <<EOF
{
    "apps": {
        "user_ldap": {
            "s01has_memberof_filter_support": "0",
            "s01home_folder_naming_rule": "",
            "s01last_jpegPhoto_lookup": "0",
            "s01ldap_agent_password": "b3duY2xvdWQxMjM=",
            "s01ldap_attributes_for_group_search": "",
            "s01ldap_attributes_for_user_search": "uid",
            "s01ldap_backup_host": "",
            "s01ldap_backup_port": "",
            "s01ldap_base": "dc=owncloudqa,dc=com",
            "s01ldap_base_groups": "dc=owncloudqa,dc=com",
            "s01ldap_base_users": "dc=owncloudqa,dc=com",
            "s01ldap_cache_ttl": "600",
            "s01ldap_configuration_active": "1",
            "s01ldap_display_name": "displayName",
            "s01ldap_dn": "cn=admin,dc=owncloudqa,dc=com",
            "s01ldap_dynamic_group_member_url": "",
            "s01ldap_email_attr": "",
            "s01ldap_experienced_admin": "0",
            "s01ldap_expert_username_attr": "uid",
            "s01ldap_expert_uuid_group_attr": "",
            "s01ldap_expert_uuid_user_attr": "",
            "s01ldap_group_display_name": "cn",
            "s01ldap_group_filter": "(&(|(objectclass=groupOfNames)))",
            "s01ldap_group_filter_mode": "0",
            "s01ldap_group_member_assoc_attribute": "member",
            "s01ldap_groupfilter_groups": "",
            "s01ldap_groupfilter_objectclass": "",
            "s01ldap_host": "openldap",
            "s01ldap_login_filter": "(&(|(objectclass=person))(|(uid=%uid)(|(dc=%uid))))",
            "s01ldap_login_filter_mode": "0",
            "s01ldap_loginfilter_attributes": "o",
            "s01ldap_loginfilter_email": "1",
            "s01ldap_loginfilter_username": "1",
            "s01ldap_nested_groups": "0",
            "s01ldap_override_main_server": "",
            "s01ldap_paging_size": "500",
            "s01ldap_port": "389",
            "s01ldap_quota_attr": "",
            "s01ldap_quota_def": "",
            "s01ldap_tls": "0",
            "s01ldap_turn_off_cert_check": "0",
            "s01ldap_user_display_name_2": "",
            "s01ldap_user_filter_mode": "0",
            "s01ldap_userfilter_groups": "",
            "s01ldap_userfilter_objectclass": "",
            "s01ldap_userlist_filter": "(objectclass=*)",
            "s01use_memberof_to_detect_membership": "1",
        }
    }
}
EOF
)
occ config:import <<< $CONFIG
occ app:enable user_ldap
occ ldap:test-config "s01"

true
