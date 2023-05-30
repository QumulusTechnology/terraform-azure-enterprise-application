
output "client_id" {
  description = "The application id of AzureAD application created."
  value       = azuread_application.this.application_id
}

output "tenant_id" {
  description = "Azure Tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "service_principal_object_id" {
  description = "The object id of service principal. Can be used to assign roles to user."
  value       = azuread_service_principal.this.object_id
}

output "service_principal_application_id" {
  description = "The object id of service principal. Can be used to assign roles to user."
  value       = azuread_service_principal.this.application_id
}

output "application_object_id" {
  description = "The object id of application."
  value       = azuread_application.this.object_id
}

output "service_principal_password" {
  description = "Password for service principal."
  value       = try(azuread_service_principal_password.this[0].value, null)
  sensitive   = true
}

output "application_password" {
  description = "Azure Application password"
  sensitive   = true
  value       = try(azuread_application_password.this[0].value, null)
}
