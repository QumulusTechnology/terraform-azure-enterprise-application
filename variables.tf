variable "name" {
  description = "Short name for the App"
  type        = string
}

variable "api_name" {
  description = "API identifier"
  type        = string
  default     = null
}

variable "display_name" {
  description = "Application Name"
  type        = string
  default     = null
}

variable "description" {
  description = "A description of the service principal provided for internal end-users."
  default     = null
}

variable "service_principal_alternative_names" {
  type        = list(string)
  description = "A set of alternative names, used to retrieve service principals by subscription, identify resource group and full resource ids for managed identities."
  default     = []
}

variable "sign_in_audience" {
  description = "The Microsoft account types that are supported for the current application. Must be one of `AzureADMyOrg`, `AzureADMultipleOrgs`, `AzureADandPersonalMicrosoftAccount` or `PersonalMicrosoftAccount`"
  default     = "AzureADMyOrg"
}

variable "redirect_uris" {
  description = "the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent"
  type        = list(string)
  default     = null
}

variable "role_definition_name" {
  description = "The name of a Azure built-in Role for the service principal"
  default     = null
  type        = string
}

variable "enable_password_rotation" {
  description = "Enable password rotation"
  default     = false
}

variable "password_end_date" {
  description = "The relative duration or RFC3339 rotation timestamp after which the password expire"
  default     = null
  type        = string
}

variable "password_rotation_in_years" {
  description = "Number of years to add to the base timestamp to configure the password rotation timestamp. Conflicts with password_end_date and either one is specified and not the both"
  default     = null
  type        = number
}

variable "password_rotation_in_days" {
  description = "Number of days to add to the base timestamp to configure the rotation timestamp. When the current time has passed the rotation timestamp, the resource will trigger recreation.Conflicts with `password_end_date`, `password_rotation_in_years` and either one must be specified, not all"
  default     = null
  type        = number
}

variable "enable_service_principal_certificate" {
  description = "Manages a Certificate associated with a Service Principal within Azure Active Directory"
  default     = false
}

variable "certificate_encoding" {
  description = "Specifies the encoding used for the supplied certificate data. Must be one of `pem`, `base64` or `hex`"
  default     = "pem"
}

variable "key_id" {
  description = "A UUID used to uniquely identify this certificate. If not specified a UUID will be automatically generated."
  default     = null
}

variable "certificate_type" {
  description = "The type of key/certificate. Must be one of AsymmetricX509Cert or Symmetric"
  default     = "AsymmetricX509Cert"
}

variable "certificate_path" {
  description = "The path to the certificate for this Service Principal"
  default     = ""
}

variable "oauth2_permission_scopes" {
  description = "List of oauth2 permission scopes this Application can request"
  type = list(object({
    name                = string
    consent_description = string
  }))
  default = []
}

variable "application_role_assignments" {
  description = "List of Application role assignments to this application"
  type = list(object({
    application       = string
    application_roles = list(string)
    delegated_roles   = list(string)
  }))
  default = []
}

variable "resource_role_assignments" {
  description = "List of Azure Subscription Resource role assignments to this service principal"
  type = list(object({
    scope = string
    role  = string
  }))
  default = []
}

variable "azuread_role_assignments" {
  description = "List of Azure AD roles to assign to to this service principal"
  type        = list(string)
  default     = []
}


variable "app_roles" {
  description = "List of application roles"
  type = list(object({
    role             = string
    groups_to_assign = list(string)
    users_to_assign  = list(string)
  }))
  default = []
}

variable "optional_claims_access_tokens" {
  description = "List of optional_claim access tokens"
  type        = list(string)
  default     = []
}

variable "optional_claims_id_tokens" {
  description = "List of optional_claim id tokens"
  type        = list(string)
  default     = []
}

variable "optional_claims_saml2_token" {
  description = "List of optional_claim saml2 tokens"
  type        = list(string)
  default     = []
}

variable "mapped_claims_enabled" {
  description = "Allows an application to use claims mapping without specifying a custom signing key"
  type        = bool
  default     = false
}

variable "app_role_assignment_required" {
  description = "Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application"
  type        = bool
  default     = false
}

variable "custom_single_sign_on" {
  description = "Whether this application represents a custom SAML application for linked service principals"
  type        = bool
  default     = false
}

variable "enterprise" {
  description = "Whether this application represents an Enterprise Application for linked service principals"
  type        = bool
  default     = false
}

variable "gallery" {
  description = "Whether this application represents a gallery application for linked service principals"
  type        = bool
  default     = false
}

variable "hide" {
  description = "Whether this app is invisible to users in My Apps and Office 365 Launcher"
  type        = bool
  default     = false
}

variable "create_application_password" {
  description = "Whether tp create an application password"
  type        = bool
  default     = true
}
