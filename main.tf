locals {
  access_token_issuance_enabled             = length(var.optional_claims_access_tokens) > 0 ? true : false
  id_token_issuance_enabled                 = length(var.optional_claims_id_tokens) > 0 ? true : false
  application_role_assignments_applications = flatten([for application_key, application in var.application_role_assignments : [application.application]])
  display_name                              = var.display_name == null ? var.name : var.display_name
  api_name                                  = var.api_name == null ? var.name : var.api_name
  azuread_users                             = tomap({ for k in data.azuread_users.all.users : k.mail => k.object_id if k.mail != "" })
  published_apps                            = { for k, v in data.azuread_application_published_app_ids.well_known.result : v => k... }
  published_apps_object_ids                 = tomap({ for k in data.azuread_users.all.users : k.mail => k.object_id if k.mail != "" })
  resource_app_ids                          = [for application_key, application in var.application_role_assignments : data.azuread_application_published_app_ids.well_known.result[application.application]]



  role_assignments = flatten([
    for application_key, application in var.application_role_assignments[*] : [
      for role in application.application_roles : {
        key                   = "${application.application}_${role}"
        role                  = role
        application           = application.application
        role_id               = azuread_service_principal.application[index(local.application_role_assignments_applications, application.application)].app_role_ids[role]
        application_object_id = azuread_service_principal.application[index(local.application_role_assignments_applications, application.application)].object_id
      }
    ]
  ])

  app_role_groups_to_assign = flatten([
    for role_key, role in var.app_roles : [
      for group in role.groups_to_assign : {
        key   = role_key
        role  = role.role
        group = group
      }
    ]
  ])

  app_role_users_to_assign = flatten([
    for role_key, role in var.app_roles : [
      for user in role.users_to_assign : {
        key  = role_key
        role = role.role
        user = user
      }
    ]
  ])
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_client_config" "current" {}

data "azuread_groups" "all" {
  return_all       = true
  security_enabled = true
}

data "azuread_users" "all" {
  return_all = true
}

resource "azuread_service_principal" "application" {
  count        = length(local.application_role_assignments_applications)
  client_id    = data.azuread_application_published_app_ids.well_known.result[local.application_role_assignments_applications[count.index]]
  use_existing = true
}

resource "random_uuid" "oauth_permission_scopes" {
  count = length(var.oauth2_permission_scopes)
}

resource "random_uuid" "application_roles" {
  count = length(var.app_roles)
}

resource "azuread_application" "this" {
  display_name     = local.display_name
  sign_in_audience = var.sign_in_audience
  identifier_uris  = ["https://${lower(var.api_name)}"]

  api {
    mapped_claims_enabled = var.mapped_claims_enabled

    dynamic "oauth2_permission_scope" {
      for_each = var.oauth2_permission_scopes
      iterator = scope
      content {
        admin_consent_description  = scope.value.consent_description
        admin_consent_display_name = scope.value.name
        enabled                    = true
        id                         = random_uuid.oauth_permission_scopes[index(var.oauth2_permission_scopes, scope.value)].result
        type                       = "User"
        user_consent_description   = scope.value.consent_description
        user_consent_display_name  = scope.value.name
        value                      = lower(scope.value.name)
      }
    }
  }

  dynamic "app_role" {
    for_each = var.app_roles
    iterator = role
    content {
      allowed_member_types = [
        "Application",
        "User",
      ]
      description  = role.value.role
      display_name = role.value.role
      enabled      = true
      id           = random_uuid.application_roles[index(var.app_roles, role.value)].result
      value        = lower(role.value.role)
    }
  }

  optional_claims {
    dynamic "access_token" {
      for_each = var.optional_claims_access_tokens
      iterator = token
      content {
        additional_properties = []
        essential             = false
        name                  = token.value
      }
    }

    dynamic "id_token" {
      for_each = var.optional_claims_id_tokens
      iterator = token
      content {
        additional_properties = []
        essential             = false
        name                  = token.value
      }
    }

    dynamic "saml2_token" {
      for_each = var.optional_claims_saml2_tokens
      iterator = token
      content {
        additional_properties = []
        essential             = false
        name                  = token.value
      }
    }

  }

  web {
    homepage_url  = var.homepage_url
    redirect_uris = var.redirect_uris
    implicit_grant {
      access_token_issuance_enabled = local.access_token_issuance_enabled
      id_token_issuance_enabled     = local.id_token_issuance_enabled
    }
  }

  public_client {
    redirect_uris = var.public_client_redirect_uris
  }

  dynamic "required_resource_access" {
    for_each = var.application_role_assignments
    iterator = app
    content {

      resource_app_id = data.azuread_application_published_app_ids.well_known.result[app.value.application]
      dynamic "resource_access" {
        for_each = app.value.application_roles
        iterator = role
        content {
          id   = azuread_service_principal.application[index(local.application_role_assignments_applications, app.value.application)].app_role_ids[role.value]
          type = "Role"
        }
      }

      dynamic "resource_access" {
        for_each = app.value.delegated_roles
        iterator = role
        content {
          id   = azuread_service_principal.application[index(local.application_role_assignments_applications, app.value.application)].oauth2_permission_scope_ids[role.value]
          type = "Scope"
        }
      }

    }
  }

  feature_tags {
    custom_single_sign_on = var.custom_single_sign_on
    enterprise            = var.enterprise
    gallery               = var.gallery
    hide                  = var.hide
  }

  group_membership_claims = var.group_membership_claims

  lifecycle {
    ignore_changes = [
      owners
    ]
  }
}

resource "azuread_application_password" "this" {
  count          = var.create_application_password ? 1 : 0
  application_id = azuread_application.this.id
}

resource "azuread_service_principal" "this" {
  client_id                     = azuread_application.this.client_id
  app_role_assignment_required  = var.app_role_assignment_required
  alternative_names             = var.service_principal_alternative_names
  description                   = var.description
  notification_email_addresses  = var.saml_cert_notification_email_addresses
  preferred_single_sign_on_mode = var.preferred_single_sign_on_mode
  tags                          = var.azuread_service_principal_tags
  lifecycle {
    ignore_changes = [
      owners
    ]
  }
}

resource "time_rotating" "this" {
  count            = var.enable_password_rotation ? 1 : 0
  rotation_rfc3339 = var.password_end_date
  rotation_years   = var.password_rotation_in_years
  rotation_days    = var.password_rotation_in_days

  triggers = {
    end_date = var.password_end_date
    years    = var.password_rotation_in_years
    days     = var.password_rotation_in_days
  }
}

resource "azuread_service_principal_password" "this" {
  count                = var.create_service_principal_password ? 1 : 0
  service_principal_id = azuread_service_principal.this.id
  rotate_when_changed = {
    rotation = var.enable_password_rotation ? time_rotating.this[0].id : null
  }
}

resource "azuread_directory_role" "this" {
  count        = length(var.azuread_role_assignments)
  display_name = var.azuread_role_assignments[count.index]
}

resource "azuread_directory_role_assignment" "this" {
  count               = length(var.azuread_role_assignments)
  role_id             = azuread_directory_role.this[count.index].object_id
  principal_object_id = azuread_service_principal.this.object_id
}

resource "azuread_app_role_assignment" "groups" {
  for_each            = { for arg in local.app_role_groups_to_assign : "${arg.group}.${arg.key}" => arg }
  app_role_id         = tolist(azuread_application.this.app_role)[each.value.key].id
  resource_object_id  = azuread_service_principal.this.object_id
  principal_object_id = data.azuread_groups.all.object_ids[index(data.azuread_groups.all.display_names, each.value.group)]
}

resource "azuread_app_role_assignment" "users" {
  for_each            = { for arg in local.app_role_users_to_assign : "${arg.user}.${arg.key}" => arg }
  app_role_id         = tolist(azuread_application.this.app_role)[each.value.key].id
  resource_object_id  = azuread_service_principal.this.object_id
  principal_object_id = local.azuread_users[each.value.user]
}

resource "azuread_app_role_assignment" "this" {
  for_each            = { for assignment in local.role_assignments : assignment.key => assignment }
  app_role_id         = each.value.role_id
  principal_object_id = azuread_service_principal.this.object_id
  resource_object_id  = each.value.application_object_id
}

data "azuread_service_principal" "resource_app" {
  count     = length(local.resource_app_ids)
  client_id = local.resource_app_ids[count.index]
}

resource "azuread_service_principal" "application_role_assignments" {
  count        = length(var.application_role_assignments)
  client_id    = data.azuread_application_published_app_ids.well_known.result[var.application_role_assignments[count.index].application]
  use_existing = true
}

resource "azuread_service_principal_delegated_permission_grant" "delegated_roles" {
  count                                = length(var.application_role_assignments)
  service_principal_object_id          = azuread_service_principal.this.object_id
  resource_service_principal_object_id = azuread_service_principal.application_role_assignments[count.index].object_id
  claim_values                         = var.application_role_assignments[count.index].delegated_roles
}
