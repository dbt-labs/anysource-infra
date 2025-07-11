########################################################################################################################
# Application - Core Required Variables
variable "region" {
  type        = string
  description = "AWS region"
  default = "us-east-1"
}

variable "profile" {
  type        = string
  description = "AWS profile"
  default     = "default"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "anysource"
}

variable "environment" {
  description = "Environment (production, staging, development)"
  type        = string
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be one of: production, staging, development"
  }
  default = "development"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the application"
}

variable "first_superuser" {
  type        = string
  description = "Email address for the first superuser account (typically your company admin email)"
  default = "taylor.brudos@dbtlabs.com"
}

variable "account" {
  type = string
  default = "783634644742"
}

# VPC Configuration with Smart Defaults
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "region_az" {
  type        = list(string)
  description = "Availability zones"
  default     = [] # Will be auto-populated based on region if empty
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Database Configuration - Simplified
variable "database_name" {
  description = "Database name"
  type        = string
  default     = "anysource"
}

variable "database_config" {
  description = "Database configuration (all optional)"
  type = object({
    engine_version      = optional(string, "16.6")
    min_capacity        = optional(number, 2)
    max_capacity        = optional(number, 16)
    publicly_accessible = optional(bool, false)
    backup_retention    = optional(number, 7)
    subnet_type         = optional(string, "private") # "public" or "private"
  })
  default = {}
}

# ALB/Security Configuration
variable "alb_access_type" {
  description = "ALB access type (public allows internet access, private restricts to VPC)"
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.alb_access_type)
    error_message = "ALB access type must be 'public' or 'private'."
  }
}

variable "alb_allowed_cidrs" {
  description = "CIDR blocks allowed to access the ALB (only applies to public ALBs)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# SSL Certificate Configuration
variable "ssl_certificate_arn" {
  description = "Existing SSL certificate ARN (optional - will create new ACM certificate if not provided)"
  type        = string
  default     = ""
}

variable "create_route53_records" {
  description = "Whether to create Route53 DNS records for the domain"
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID (required if create_route53_records is true)"
  type        = string
  default     = ""
}

# Application Services Configuration with Smart Defaults
variable "services_configurations" {
  type = map(object({
    path_pattern                      = list(string)
    health_check_path                 = string
    protocol                          = optional(string, "HTTP")
    port                              = optional(number, 80)
    cpu                               = optional(number, 512)  # Increased default for production
    memory                            = optional(number, 1024) # Increased default for production
    host_port                         = optional(number, 8000)
    container_port                    = optional(number, 8000)
    desired_count                     = optional(number, 2) # Production-ready default
    max_capacity                      = optional(number, 2) # Allow scaling
    min_capacity                      = optional(number, 2)
    cpu_auto_scalling_target_value    = optional(number, 70)
    memory_auto_scalling_target_value = optional(number, 80)
    priority                          = optional(number) # Priority for ALB listener rules
    env_vars                          = optional(map(string), {})
    secret_vars                       = optional(map(string), {})
  }))
  default = {
    "backend" = {
      name              = "backend"
      path_pattern      = ["/api/*"]
      health_check_path = "/api/v1/utils/health-check/"
      container_port    = 8000
      host_port         = 8000
      port              = 8000
      priority          = 1
    }
    "frontend" = {
      name              = "frontend"
      path_pattern      = ["/*"]
      health_check_path = "/"
      container_port    = 80
      host_port         = 80
      priority          = 2
    }
  }
}

# HuggingFace Configuration
variable "hf_token" {
  type        = string
  description = "HuggingFace token for downloading models (used by prompt protection)"
  default     = "" # Must be provided via tfvars or environment variable
  sensitive   = true
}

# Optional Global Environment Variables
variable "env_vars" {
  type        = map(string)
  description = "Global environment variables for all services"
  default     = {}
}

variable "secret_vars" {
  type        = map(string)
  description = "Global secret variables for all services"
  default     = {}
}

# S3 Configuration (Optional)
variable "buckets_conf" {
  type        = map(object({ acl = string }))
  description = "S3 bucket configurations"
  default     = {}
}

variable "buckets_conf_new" {
  type        = map(object({ acl = string }))
  description = "Additional S3 bucket configurations"
  default     = {}
}

# Monitoring and Alerting Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = false
}

variable "enable_chatbot_alerts" {
  description = "Enable monitoring alerts via AWS Chatbot (much simpler than SNS for enterprise)"
  type        = bool
  default     = false
}

variable "slack_channel_id" {
  description = "Slack channel ID for alerts (e.g., C1234567890)"
  type        = string
  default     = ""
}

variable "slack_team_id" {
  description = "Slack team/workspace ID (e.g., T1234567890)"
  type        = string
  default     = ""
}



# Legacy variables removed - use database_config instead

variable "suffix_secret_hash" {
  type        = string
  description = "Suffix for secret names to ensure uniqueness"
  default     = ""
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection for RDS clusters"
  default     = true
}
