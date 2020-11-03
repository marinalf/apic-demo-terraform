

###########################LOGICAL##############################

#Tenant

resource "aci_tenant" "terraform-tenant" {
     name             = var.tenant_name
     description      = "This tenant is created by terraform."
}

#VRF

resource "aci_vrf" "terraform-vrf" {
    tenant_dn         = aci_tenant.terraform-tenant.id
    name              = var.vrf_name
}

#Bridge domains

resource "aci_bridge_domain" "terraform-bd-Web" {
    tenant_dn          = aci_tenant.terraform-tenant.id
    relation_fv_rs_ctx = aci_vrf.terraform-vrf.id
    name               = "Web-BD"
}

resource "aci_subnet" "terraform-gateway-Web" {
     parent_dn         = aci_bridge_domain.terraform-bd-Web.id
     ip                = "10.0.0.254/24"
     scope             = ["private"]
}

resource "aci_bridge_domain" "terraform-bd-DB" {
    tenant_dn          = aci_tenant.terraform-tenant.id
    relation_fv_rs_ctx = aci_vrf.terraform-vrf.id
    name               = "DB-BD"
}
resource "aci_subnet" "terraform-gateway-DB" {
       parent_dn       = aci_bridge_domain.terraform-bd-DB.id
     ip                = "10.0.1.254/24"
     scope             = ["private"]
}

#Application profile

resource "aci_application_profile" "terraform-app" {
     tenant_dn         = aci_tenant.terraform-tenant.id
     name              = "MyApp"
}

#EPGs

resource "aci_application_epg" "terraform-epg-web" {
     application_profile_dn = aci_application_profile.terraform-app.id
     relation_fv_rs_bd      = aci_bridge_domain.terraform-bd-Web.id
     name                   = "Web-EPG"
/*
     name_alias = "EPG_Alias"
     relation_fv_rs_dom_att = ["uni/phys-terraform_domain"]
*/
}

resource "aci_application_epg" "terraform-epg-db" {
     application_profile_dn = aci_application_profile.terraform-app.id
     relation_fv_rs_bd      = aci_bridge_domain.terraform-bd-DB.id
     name                   = "DB-EPG"
}
