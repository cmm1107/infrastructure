terraform {
  backend "pg" {
    schema_name = "terraform_remote_state_stage1"
  }
}

data "external" "vault_hetzner" {
  program = [
    "${path.module}/../misc/get_key.py", "misc/vault_hetzner.yml",
    "hetzner_cloud_api_key",
    "hetzner_dns_api_key",
    "--format", "json"
  ]
}

data "hcloud_image" "archlinux" {
  with_selector = "custom_image=archlinux"
  most_recent   = true
  with_status   = ["available"]
}

provider "hcloud" {
  token = data.external.vault_hetzner.result.hetzner_cloud_api_key
}

provider "hetznerdns" {
  apitoken = data.external.vault_hetzner.result.hetzner_dns_api_key
}

variable "archlinux_org_cname" {
  type = map(any)
  default = {
    archive                  = { value = "gemini", ttl = null }
    dev                      = { value = "www", ttl = 600 }
    g2kjxsblac7x             = { value = "gv-i5y6mnrelvpfiu.dv.googlehosted.com.", ttl = null }
    git                      = { value = "luna", ttl = null }
    grafana                  = { value = "apollo", ttl = null }
    ipxe                     = { value = "www", ttl = 600 }
    "luna2._domainkey.aur"   = { value = "luna2._domainkey", ttl = null }
    "luna2._domainkey.lists" = { value = "luna2._domainkey", ttl = null }
    mailman                  = { value = "apollo", ttl = null }
    packages                 = { value = "www", ttl = 600 }
    planet                   = { value = "www", ttl = 600 }
    projects                 = { value = "luna", ttl = null }
    repos                    = { value = "gemini", ttl = null }
    rsync                    = { value = "gemini", ttl = null }
    sources                  = { value = "gemini", ttl = null }
    "static.conf"            = { value = "apollo", ttl = null }
    static                   = { value = "apollo", ttl = null }
    status                   = { value = "stats.uptimerobot.com.", ttl = null }
    svn                      = { value = "gemini", ttl = null }
  }
}

variable "archlinux_org_gitlab_pages" {
  type = list(object({
    name              = string
    verification_code = string
  }))
  default = [
    {
      name              = "conf"
      verification_code = "60a06a1c02e42b36c3b4919f4d6de6bf"
    },
    {
      name              = "whatcanwedofor",
      verification_code = "b5f8011047c1610ace52e754b568c834"
    }
  ]
}

resource "hetznerdns_zone" "archlinux" {
  name = "archlinux.org"
  ttl  = 86400
}

resource "hetznerdns_zone" "pkgbuild" {
  name = "pkgbuild.com"
  ttl  = 86400
}

resource "hetznerdns_record" "pkgbuild_com_origin_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "78.46.178.133"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_origin_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "2a01:4f8:c2c:51e2::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_origin_caa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
}

resource "hetznerdns_record" "pkgbuild_com_origin_mx" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "0 ."
  type    = "MX"
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns3" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "robotns3.second-ns.com."
  type    = "NS"
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns2" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "robotns2.second-ns.de."
  type    = "NS"
}

resource "hetznerdns_record" "pkgbuild_com_origin_ns1" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "ns1.first-ns.de."
  type    = "NS"
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
# resource "hetznerdns_record" "pkgbuild_com_origin_soa" {
#   zone_id = hetznerdns_zone.pkgbuild.id
#   name = "@"
#   value = "ns1.first-ns.de. dns.hetzner.com. 2020090604 14400 1800 604800 86400"
#   type = "SOA"
# }

resource "hetznerdns_record" "pkgbuild_com_origin_txt" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "@"
  value   = "\"v=spf1 -all\""
  type    = "TXT"
}

resource "hetznerdns_record" "pkgbuild_com_wildcard_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "*"
  value   = "78.46.178.133"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_wildcard_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "*"
  value   = "2a01:4f8:c2c:51e2::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_mirror_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "mirror"
  value   = "78.46.209.220"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_mirror_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "mirror"
  value   = "2a01:4f8:c2c:c62f::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_america_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "america.mirror"
  value   = "143.244.34.62"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_america_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "america.mirror"
  value   = "2a02:6ea0:cc0e::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_america_archive_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "america.archive"
  value   = "143.244.34.62"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_america_archive_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "america.archive"
  value   = "2a02:6ea0:cc0e::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_asia_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "asia.mirror"
  value   = "84.17.57.98"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_asia_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "asia.mirror"
  value   = "2a02:6ea0:d605::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_asia_archive_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "asia.archive"
  value   = "84.17.57.98"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_asia_archive_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "asia.archive"
  value   = "2a02:6ea0:d605::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_europe_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "europe.mirror"
  value   = "89.187.191.12"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_europe_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "europe.mirror"
  value   = "2a02:6ea0:c237::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_europe_archive_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "europe.archive"
  value   = "89.187.191.12"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_europe_archive_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "europe.archive"
  value   = "2a02:6ea0:c237::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_repro1_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "repro1"
  value   = "147.75.81.79"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_repro1_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "repro1"
  value   = "2604:1380:2001:4500::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_repro2_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "repro2"
  value   = "212.102.38.209"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_repro2_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "repro2"
  value   = "2a02:6ea0:c238::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "pkgbuild_com_www_a" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "www"
  value   = "78.46.178.133"
  type    = "A"
}

resource "hetznerdns_record" "pkgbuild_com_www_aaaa" {
  zone_id = hetznerdns_zone.pkgbuild.id
  name    = "www"
  value   = "2a01:4f8:c2c:51e2::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_cname" {
  for_each = var.archlinux_org_cname

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.key
  ttl     = each.value.ttl
  value   = each.value.value
  type    = "CNAME"
}


resource "hetznerdns_record" "archlinux_org_origin_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  ttl     = 600
  value   = hcloud_server.archlinux.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_origin_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  ttl     = 600
  value   = hcloud_server.archlinux.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_origin_caa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "0 issue \"letsencrypt.org\""
  type    = "CAA"
}

resource "hetznerdns_record" "archlinux_org_origin_ns3" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "robotns3.second-ns.com."
  type    = "NS"
}

resource "hetznerdns_record" "archlinux_org_origin_ns2" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "robotns2.second-ns.de."
  type    = "NS"
}

resource "hetznerdns_record" "archlinux_org_origin_ns1" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "@"
  value   = "ns1.first-ns.de."
  type    = "NS"
}

# TODO: Commented currently as we have no idea how to handle SOA stuff with Terraform:
# https://github.com/timohirt/terraform-provider-hetznerdns/issues/20
# https://gitlab.archlinux.org/archlinux/infrastructure/-/merge_requests/62#note_4040
#; resource "hetznerdns_record" "archlinux_org_origin_soa" {
#   zone_id = hetznerdns_zone.archlinux.id
#   name = "@"
#   value = "ns1.first-ns.de. ibiru.archlinux.org. 2020072502 7200 900 1209600 86400"
#   type = "SOA"
# }

resource "hetznerdns_record" "archlinux_org_origin_apollo_domainkey_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "apollo._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvZIf8SbjC53RDCbMjTEpo0FCuMSShlKWdwWjY1J+RpT3CL/21z4nXqVBYF1orkUScH8Nlabocraqk8lmpNBlKCUV77lk9mRsLkWhg+XjhvQXL1xfH8zAg1CntEZuaIMLUQ+5Gkw6BlO1qDRkmXS9UtV8Jt1rhjRtSrgN5lhztOCbQLRAtzKty/nMeClqsfT3nL2hbDeh+b/rYc\" \"l2veZAqiGcR2/0bnKlt+Nb5lOBY3oZiYLmZ5g+l9UXVjGUq9jGAooIWpQvuRPmin3RX31kXfr1A+mDBEexiOL1dDST2Zx7i9puXbqYH0u0IxBpweHCO5UqWx52mdXBuhs+DCo/JoZAHU/6eRzK+Sps50LgLFSzJJNfGXk5PUKdww2GHbkK3mCYfoFCpB0SADzl42+1w6YZk1yXoPdOHtChfQpCgjtddf1W8Q09pYO1/bn4l0erdFQsWb1K\" \"4wEVOCn+hHWbV42V+J3TyGxQ4AM8KQ1OPvUEabyTyqcO4evBaH7/S2wA91Z9QDjTbKmlNovs5zoxuOM/mPGPUuQMvhjoAP+rg4AwJ3Xwd3GgUcqQflcokayUYdp7F3aKp1NWAR9ibseU/XBYsSF8Ucjqzf4DJFUfrgjHUr97st7g4HUCyXrQO4tyE0ytiX8OFjjIszWLmF+B7Vup9O7k+dNz2Vj2Vyzkq1UCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_accounts_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "accounts"
  value   = hcloud_server.accounts.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_accounts_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "accounts"
  value   = hcloud_server.accounts.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_apollo_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "apollo"
  ttl     = 600
  value   = "138.201.81.199"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_apollo_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "apollo"
  ttl     = 600
  value   = "2a01:4f8:172:1d86::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_aur_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur"
  value   = hcloud_server.aur.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur"
  value   = hcloud_server.aur.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_aur_dev_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur-dev"
  value   = hcloud_server.aur-dev.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur_dev_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur-dev"
  value   = hcloud_server.aur-dev.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_aur4_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur4"
  value   = "5.9.250.164"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_aur4_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "aur4"
  value   = "2a01:4f8:160:3033::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_bbs_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bbs"
  value   = hcloud_server.bbs.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_bbs_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bbs"
  value   = hcloud_server.bbs.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_bugs_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bugs"
  value   = hcloud_server.bugs.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_bugs_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "bugs"
  value   = hcloud_server.bugs.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_dragon_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dragon"
  value   = "195.201.167.210"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_dragon_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dragon"
  value   = "2a01:4f8:13a:102a::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_gemini_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gemini"
  value   = "49.12.124.107"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_gemini_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gemini"
  value   = "2a01:4f8:242:5614::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_gitlab_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gitlab"
  value   = hcloud_server.gitlab.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_gitlab_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "gitlab"
  value   = hcloud_server.gitlab.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_homedir_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "homedir"
  value   = hcloud_server.homedir.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_homedir_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "homedir"
  value   = hcloud_server.homedir.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_lists_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  value   = "5.9.250.164"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_lists_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  value   = "2a01:4f8:160:3033::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_lists_mx" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  ttl     = 600
  value   = "10 luna"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_lists_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "lists"
  ttl     = 600
  # lists.archlinux.org
  value = "\"v=spf1 ip4:5.9.250.164 ip6:2a01:4f8:160:3033::2 ~all\""
  type  = "TXT"
}

resource "hetznerdns_record" "archlinux_org_luna_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna"
  ttl     = 600
  value   = "5.9.250.164"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_luna_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna"
  ttl     = 600
  value   = "2a01:4f8:160:3033::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_luna_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvXrAPvtdX8Jrk4zmyk8w9T2zdAJGe7z0+4XHWWiuzH8Zse6S7oXiS9CVaPOsu0TZqHqhuclASU7qh0NXFwWyi2xRPyJOqH2Clu7vHS3j5F4TjURFOp4/EbA0iQu4rbItl4AU11z2pGSEj5SykUsrH+jjdqzNqAG9d4lNvkTs6RRzPF3KhhY+XljaeysEyDSS4ap4E0DYcduSIX\" \"oD1exFv4SEbXThD9PC1u81w4xusnmwmfHtR7aazeqPDP+S+FqDRy2woCaQb/VMbqMYVuWTVKJ2RxFyTKredOOV2c5kzih7GViwoetll/rTqO4aVbeir9K4f6YZg85dSQtVwEat7LV+zBnQwp3ivWkrIk8VEdSsCSaJlgattBiPHsfFFv1xw4qi3h+UvfCGgz35dtlnzd/noGhNARg0Z+kaMSTjy75V1mKx5sCH0o8nAX2XU8akJfLz58Vg\" \"kTx/sfealtwNA0gTy1t1jV8q0OF5RA0IeMRgCzeH2USOZI98W+EAUsGG5653Vzmp3FJRWp1tWJwRJ0M/aZ3ka/G1iTx3rNNcadVk+4q3gz3KnlAlun+m58y8pNWKjYuxmu9xkDRwM/33rv98j0R8HZO7HFL+1vjKkxSEuzmnTQ2O9F76/OsQoDPZ1Z6nJRvK8ts8PQr4ASKohby62+1F1M8U2Xn7u84dYLUCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_luna2_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna2._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; s=email; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvXrAPvtdX8Jrk4zmyk8w9T2zdAJGe7z0+4XHWWiuzH8Zse6S7oXiS9CVaPOsu0TZqHqhuclASU7qh0NXFwWyi2xRPyJOqH2Clu7vHS3j5F4TjURFOp4/EbA0iQu4rbItl4AU11z2pGSEj5SykUsrH+jjdqzNqAG9d4lNvkTs6RRzPF3KhhY+XljaeysEyDSS4ap4E0DYcduSIX\" \"oD1exFv4SEbXThD9PC1u81w4xusnmwmfHtR7aazeqPDP+S+FqDRy2woCaQb/VMbqMYVuWTVKJ2RxFyTKredOOV2c5kzih7GViwoetll/rTqO4aVbeir9K4f6YZg85dSQtVwEat7LV+zBnQwp3ivWkrIk8VEdSsCSaJlgattBiPHsfFFv1xw4qi3h+UvfCGgz35dtlnzd/noGhNARg0Z+kaMSTjy75V1mKx5sCH0o8nAX2XU8akJfLz58Vg\" \"kTx/sfealtwNA0gTy1t1jV8q0OF5RA0IeMRgCzeH2USOZI98W+EAUsGG5653Vzmp3FJRWp1tWJwRJ0M/aZ3ka/G1iTx3rNNcadVk+4q3gz3KnlAlun+m58y8pNWKjYuxmu9xkDRwM/33rv98j0R8HZO7HFL+1vjKkxSEuzmnTQ2O9F76/OsQoDPZ1Z6nJRvK8ts8PQr4ASKohby62+1F1M8U2Xn7u84dYLUCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_luna3_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "luna"
  ttl     = 600
  value   = "\"v=spf1 include:lists.archlinux.org -all\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_mailman3_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mailman3"
  value   = hcloud_server.mailman3.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_mailman3_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mailman3"
  value   = hcloud_server.mailman3.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_master_key_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "master-key"
  ttl     = 600
  value   = hcloud_server.archlinux.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_master_key_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "master-key"
  ttl     = 600
  value   = hcloud_server.archlinux.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_matrix_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "matrix"
  value   = hcloud_server.matrix.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_matrix_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "matrix"
  value   = hcloud_server.matrix.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_monitoring_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "monitoring"
  value   = hcloud_server.monitoring.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_monitoring_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "monitoring"
  value   = hcloud_server.monitoring.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_mail_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mail"
  ttl     = 600
  value   = hcloud_server.mail.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_mail_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "mail"
  ttl     = 600
  value   = hcloud_server.mail.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_mtasts_cname" {
  for_each = toset(["", ".aur", ".master-key", ".lists"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = "mta-sts${each.value}"
  value   = "mail"
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org__mtasts_txt" {
  for_each = toset(["", ".aur", ".master-key", ".lists"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_mta-sts${each.value}"
  ttl     = 600
  # date +%s
  value = "\"v=STSv1; id=1608210175\""
  type  = "TXT"
}

resource "hetznerdns_record" "archlinux_org_origin_mx" {
  for_each = toset(["@", "aur", "master-key"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.value
  ttl     = 600
  value   = "10 mail"
  type    = "MX"
}

resource "hetznerdns_record" "archlinux_org_origin_txt" {
  for_each = toset(["@", "aur", "mail", "master-key"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.value
  ttl     = 600
  # mail.archlinux.org
  value = "\"v=spf1 ip4:95.216.189.61 ip6:2a01:4f9:c010:3052::1 ~all\""
  type  = "TXT"
}

resource "hetznerdns_record" "archlinux_org_domainkey_dkim-ed25519_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dkim-ed25519._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=ed25519; \" \"p=XOHB7b7V1puX+FryNIhsjXHYIFqk+q6JRu4XQ7Jc8MQ=\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_domainkey_dkim-rsa_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "dkim-rsa._domainkey"
  ttl     = 600
  value   = "\"v=DKIM1; k=rsa; \" \"p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1GjGrEczq7iHZbvT7wa4ltJz2jwSndUGdRHgfEPnGBeevOXEAlEFr4zsdkfZEaNaQLIhZNpvKAt/A+kkyalkj4u9AnxqeNsNmZflFl6TKgvh0tWNEP3+XNxfdQ7zfml4WggL/YdAjXngg42oZEUsnS/6iozOFn7bNvzqBx5PFJ21pgyuR8DWyLaeOt+p55dVed7DCKnKi11Xjiu7k\" \"H68W8rose7g8Fv9fecBatEE4jwloOXsjh+tH0iab1NSSSpIq6EdgcPrpmrllN3/n2J/kCGK6ztISB6vR7xWgvgHSMjmEL0GPWzohGPrw2UQhZhrNV8dJpiLRYmfK+rXaKF0Kqag/F0e4C4jCKFX7NYFcYXYRlN5QlDFjZvUmOILlgnZ8w/SdZUKzpLObGuwnANLG+WSOjw42p9mXVGN6AfOQPu8OjRjS1MyhcdDIbUvZiQjbmiVJ5frpYZ39BTg\" \"CIzYLJJ5932+3gnwROu1OeljWkpBkfHZXPzADus80l3Vxsk91XZVB36rN8tyuMownR/M4HNC7ZE/EBwOnn1mGH7bLd6pva8u5Qy8Y6LrDdYea5Kk7aZ2WJSSRTV+nkPvOEIx+DfsIWNfmkVWzmuVky96fRvwOCuh38w8zpmlqzhDuGSQrBaLFXwAC7LYQ6kPDHzrjQhs99ScR0ix6YclrmpimMcCAwEAAQ==\" "
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_dmarc_txt" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_dmarc"
  value   = "\"v=DMARC1; p=none; rua=mailto:dmarc-reports@archlinux.org; ruf=mailto:dmarc-reports@archlinux.org;\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_smtp_tlsrpt_txt" {
  for_each = toset(["", ".aur", ".master-key", ".lists"])

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_smtp._tls${each.value}"
  value   = "\"v=TLSRPTv1;rua=mailto:postmaster@archlinux.org\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_openpgpkey_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "openpgpkey"
  value   = hcloud_server.openpgpkey.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_openpgpkey_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "openpgpkey"
  value   = hcloud_server.openpgpkey.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_phrik_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "phrik"
  value   = hcloud_server.phrik.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_phrik_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "phrik"
  value   = hcloud_server.phrik.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_quassel_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "quassel"
  value   = hcloud_server.quassel.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_quassel_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "quassel"
  value   = hcloud_server.quassel.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_reproducible_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "reproducible"
  value   = hcloud_server.reproducible.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_reproducible_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "reproducible"
  value   = hcloud_server.reproducible.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_runner1_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "runner1"
  value   = "84.17.49.250"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_runner1_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "runner1"
  value   = "2a02:6ea0:c719::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_runner2_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "runner2"
  value   = "147.75.80.217"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_runner2_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "runner2"
  value   = "2604:1380:2001:4500::3"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_secure_runner1_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "secure-runner1"
  value   = "116.202.134.150"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_secure_runner1_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "secure-runner1"
  value   = "2a01:4f8:231:4e1e::2"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_svn2gittest_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "svn2gittest"
  value   = hcloud_server.svn2gittest.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_svn2gittest_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "svn2gittest"
  value   = hcloud_server.svn2gittest.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_state_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "state"
  value   = "116.203.16.252"
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_state_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "state"
  value   = "2a01:4f8:c2c:474::1"
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_patchwork_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "patchwork"
  ttl     = 600
  value   = hcloud_server.patchwork.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_patchwork_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "patchwork"
  ttl     = 600
  value   = hcloud_server.patchwork.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_security_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "security"
  ttl     = 600
  value   = hcloud_server.security.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_security_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "security"
  ttl     = 600
  value   = hcloud_server.security.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_wiki_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "wiki"
  ttl     = 600
  value   = hcloud_server.archwiki.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_wiki_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "wiki"
  ttl     = 600
  value   = hcloud_server.archwiki.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_www_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "www"
  ttl     = 600
  value   = hcloud_server.archlinux.ipv4_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_www_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "www"
  ttl     = 600
  value   = hcloud_server.archlinux.ipv6_address
  type    = "AAAA"
}

resource "hetznerdns_record" "archlinux_org_matrix_tcp_srv" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_matrix._tcp"
  value   = "10 0 8448 matrix"
  type    = "SRV"
}

resource "hetznerdns_record" "archlinux_org_github_challenge_archlinux" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_github-challenge-archlinux"
  value   = "\"824af4446e\""
  type    = "TXT"
}

resource "hetznerdns_record" "archlinux_org_github_challenge_archlinux_www" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "_github-challenge-archlinux.www"
  value   = "\"b53f311f86\""
  type    = "TXT"
}

resource "hcloud_rdns" "quassel_ipv4" {
  server_id  = hcloud_server.quassel.id
  ip_address = hcloud_server.quassel.ipv4_address
  dns_ptr    = "quassel.archlinux.org"
}

resource "hcloud_rdns" "quassel_ipv6" {
  server_id  = hcloud_server.quassel.id
  ip_address = hcloud_server.quassel.ipv6_address
  dns_ptr    = "quassel.archlinux.org"
}

resource "hcloud_server" "quassel" {
  name        = "quassel.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "phrik_ipv4" {
  server_id  = hcloud_server.phrik.id
  ip_address = hcloud_server.phrik.ipv4_address
  dns_ptr    = "phrik.archlinux.org"
}

resource "hcloud_rdns" "phrik_ipv6" {
  server_id  = hcloud_server.phrik.id
  ip_address = hcloud_server.phrik.ipv6_address
  dns_ptr    = "phrik.archlinux.org"
}

resource "hcloud_server" "phrik" {
  name        = "phrik.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "bbs_ipv4" {
  server_id  = hcloud_server.bbs.id
  ip_address = hcloud_server.bbs.ipv4_address
  dns_ptr    = "bbs.archlinux.org"
}

resource "hcloud_rdns" "bbs_ipv6" {
  server_id  = hcloud_server.bbs.id
  ip_address = hcloud_server.bbs.ipv6_address
  dns_ptr    = "bbs.archlinux.org"
}

resource "hcloud_server" "bbs" {
  name        = "bbs.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx21"
  lifecycle {
    ignore_changes = [image]
  }
}


resource "hcloud_rdns" "gitlab_ipv4" {
  server_id  = hcloud_server.gitlab.id
  ip_address = hcloud_server.gitlab.ipv4_address
  dns_ptr    = "gitlab.archlinux.org"
}

resource "hcloud_rdns" "gitlab_ipv6" {
  server_id  = hcloud_server.gitlab.id
  ip_address = hcloud_server.gitlab.ipv6_address
  dns_ptr    = "gitlab.archlinux.org"
}

resource "hcloud_server" "gitlab" {
  name        = "gitlab.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx51"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hetznerdns_record" "archlinux_org_gitlab_pages_a" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "pages"
  value   = hcloud_floating_ip.gitlab_pages.ip_address
  type    = "A"
}

resource "hetznerdns_record" "archlinux_org_gitlab_pages_aaaa" {
  zone_id = hetznerdns_zone.archlinux.id
  name    = "pages"
  value   = var.gitlab_pages_ipv6
  type    = "AAAA"
}

resource "hcloud_floating_ip" "gitlab_pages" {
  type        = "ipv4"
  description = "GitLab Pages"
  server_id   = hcloud_server.gitlab.id
}

variable "gitlab_pages_ipv6" {
  default = "2a01:4f8:c2c:5d2d::2"
}

resource "hetznerdns_record" "archlinux_org_gitlab_pages_cname" {
  for_each = { for p in var.archlinux_org_gitlab_pages : p.name => p }

  zone_id = hetznerdns_zone.archlinux.id
  name    = each.value.name
  value   = "pages.archlinux.org."
  type    = "CNAME"
}

resource "hetznerdns_record" "archlinux_org_gitlab_pages_verification_code_txt" {
  for_each = { for p in var.archlinux_org_gitlab_pages : p.name => p }

  zone_id = hetznerdns_zone.archlinux.id
  name    = "_gitlab-pages-verification-code.${each.value.name}"
  value   = "gitlab-pages-verification-code=${each.value.verification_code}"
  type    = "TXT"
}

resource "hcloud_volume" "gitlab" {
  name      = "gitlab"
  size      = 1000
  server_id = hcloud_server.gitlab.id
}


resource "hcloud_rdns" "matrix_ipv4" {
  server_id  = hcloud_server.matrix.id
  ip_address = hcloud_server.matrix.ipv4_address
  dns_ptr    = "matrix.archlinux.org"
}

resource "hcloud_rdns" "matrix_ipv6" {
  server_id  = hcloud_server.matrix.id
  ip_address = hcloud_server.matrix.ipv6_address
  dns_ptr    = "matrix.archlinux.org"
}

resource "hcloud_server" "matrix" {
  name        = "matrix.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cpx31"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "acccounts_ipv4" {
  server_id  = hcloud_server.accounts.id
  ip_address = hcloud_server.accounts.ipv4_address
  dns_ptr    = "accounts.archlinux.org"
}

resource "hcloud_rdns" "acccounts_ipv6" {
  server_id  = hcloud_server.accounts.id
  ip_address = hcloud_server.accounts.ipv6_address
  dns_ptr    = "accounts.archlinux.org"
}

resource "hcloud_server" "accounts" {
  name        = "accounts.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  provisioner "local-exec" {
    working_dir = ".."
    command     = "ansible-playbook --ssh-extra-args '-o StrictHostKeyChecking=no' playbooks/accounts.archlinux.org.yml"
  }
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_volume" "mirror" {
  name      = "mirror"
  size      = 100
  server_id = hcloud_server.mirror.id
}

resource "hcloud_rdns" "mirror_ipv4" {
  server_id  = hcloud_server.mirror.id
  ip_address = hcloud_server.mirror.ipv4_address
  dns_ptr    = "mirror.pkgbuild.com"
}

resource "hcloud_rdns" "mirror_ipv6" {
  server_id  = hcloud_server.mirror.id
  ip_address = hcloud_server.mirror.ipv6_address
  dns_ptr    = "mirror.pkgbuild.com"
}

resource "hcloud_server" "mirror" {
  name        = "mirror.pkgbuild.com"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}


resource "hcloud_rdns" "homedir_ipv4" {
  server_id  = hcloud_server.homedir.id
  ip_address = hcloud_server.homedir.ipv4_address
  dns_ptr    = "homedir.archlinux.org"
}

resource "hcloud_rdns" "homedir_ipv6" {
  server_id  = hcloud_server.homedir.id
  ip_address = hcloud_server.homedir.ipv6_address
  dns_ptr    = "homedir.archlinux.org"
}

resource "hcloud_server" "homedir" {
  name        = "homedir.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_volume" "homedir" {
  name      = "homedir"
  size      = 100
  server_id = hcloud_server.homedir.id
}

resource "hcloud_rdns" "bugs_ipv4" {
  server_id  = hcloud_server.bugs.id
  ip_address = hcloud_server.bugs.ipv4_address
  dns_ptr    = "bugs.archlinux.org"
}

resource "hcloud_rdns" "bugs_ipv6" {
  server_id  = hcloud_server.bugs.id
  ip_address = hcloud_server.bugs.ipv6_address
  dns_ptr    = "bugs.archlinux.org"
}

resource "hcloud_server" "bugs" {
  name        = "bugs.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "aur_ipv4" {
  server_id  = hcloud_server.aur.id
  ip_address = hcloud_server.aur.ipv4_address
  dns_ptr    = "aur.archlinux.org"
}

resource "hcloud_rdns" "aur_ipv6" {
  server_id  = hcloud_server.aur.id
  ip_address = hcloud_server.aur.ipv6_address
  dns_ptr    = "aur.archlinux.org"
}

resource "hcloud_server" "aur" {
  name        = "aur.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cpx41"
  keep_disk   = true
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "aur-dev_ipv4" {
  server_id  = hcloud_server.aur-dev.id
  ip_address = hcloud_server.aur-dev.ipv4_address
  dns_ptr    = "aur-dev.archlinux.org"
}

resource "hcloud_rdns" "aur-dev_ipv6" {
  server_id  = hcloud_server.aur-dev.id
  ip_address = hcloud_server.aur-dev.ipv6_address
  dns_ptr    = "aur-dev.archlinux.org"
}

resource "hcloud_server" "aur-dev" {
  name        = "aur-dev.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "mailman3_ipv4" {
  server_id  = hcloud_server.mailman3.id
  ip_address = hcloud_server.mailman3.ipv4_address
  dns_ptr    = "mailman3.archlinux.org"
}

resource "hcloud_rdns" "mailman3_ipv6" {
  server_id  = hcloud_server.mailman3.id
  ip_address = hcloud_server.mailman3.ipv6_address
  dns_ptr    = "mailman3.archlinux.org"
}

resource "hcloud_server" "mailman3" {
  name        = "mailman3.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "reproducible_ipv4" {
  server_id  = hcloud_server.reproducible.id
  ip_address = hcloud_server.reproducible.ipv4_address
  dns_ptr    = "reproducible.archlinux.org"
}

resource "hcloud_rdns" "reproducible_ipv6" {
  server_id  = hcloud_server.reproducible.id
  ip_address = hcloud_server.reproducible.ipv6_address
  dns_ptr    = "reproducible.archlinux.org"
}

resource "hcloud_server" "reproducible" {
  name        = "reproducible.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "monitoring_ipv4" {
  server_id  = hcloud_server.monitoring.id
  ip_address = hcloud_server.monitoring.ipv4_address
  dns_ptr    = "monitoring.archlinux.org"
}

resource "hcloud_rdns" "monitoring_ipv6" {
  server_id  = hcloud_server.monitoring.id
  ip_address = hcloud_server.monitoring.ipv6_address
  dns_ptr    = "monitoring.archlinux.org"
}

resource "hcloud_server" "monitoring" {
  name        = "monitoring.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "svn2gittest_ipv4" {
  server_id  = hcloud_server.svn2gittest.id
  ip_address = hcloud_server.svn2gittest.ipv4_address
  dns_ptr    = "svn2gittest.archlinux.org"
}

resource "hcloud_rdns" "svn2gittest_ipv6" {
  server_id  = hcloud_server.svn2gittest.id
  ip_address = hcloud_server.svn2gittest.ipv6_address
  dns_ptr    = "svn2gittest.archlinux.org"
}

resource "hcloud_server" "svn2gittest" {
  name        = "svn2gittest"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "mail_ipv4" {
  server_id  = hcloud_server.mail.id
  ip_address = hcloud_server.mail.ipv4_address
  dns_ptr    = "mail.archlinux.org"
}

resource "hcloud_rdns" "mail_ipv6" {
  server_id  = hcloud_server.mail.id
  ip_address = hcloud_server.mail.ipv6_address
  dns_ptr    = "mail.archlinux.org"
}

resource "hcloud_server" "mail" {
  name        = "mail.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "openpgpkey_ipv4" {
  server_id  = hcloud_server.openpgpkey.id
  ip_address = hcloud_server.openpgpkey.ipv4_address
  dns_ptr    = "openpgpkey.archlinux.org"
}

resource "hcloud_rdns" "openpgpkey_ipv6" {
  server_id  = hcloud_server.openpgpkey.id
  ip_address = hcloud_server.openpgpkey.ipv6_address
  dns_ptr    = "openpgpkey.archlinux.org"
}

resource "hcloud_server" "openpgpkey" {
  name        = "openpgpkey.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "archlinux_ipv4" {
  server_id  = hcloud_server.archlinux.id
  ip_address = hcloud_server.archlinux.ipv4_address
  dns_ptr    = "archlinux.org"
}

resource "hcloud_rdns" "archlinux_ipv6" {
  server_id  = hcloud_server.archlinux.id
  ip_address = hcloud_server.archlinux.ipv6_address
  dns_ptr    = "archlinux.org"
}

resource "hcloud_server" "archlinux" {
  name        = "archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cpx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "archwiki_ipv4" {
  server_id  = hcloud_server.archwiki.id
  ip_address = hcloud_server.archwiki.ipv4_address
  dns_ptr    = "wiki.archlinux.org"
}

resource "hcloud_rdns" "archwiki_ipv6" {
  server_id  = hcloud_server.archwiki.id
  ip_address = hcloud_server.archwiki.ipv6_address
  dns_ptr    = "wiki.archlinux.org"
}

resource "hcloud_server" "archwiki" {
  name        = "wiki.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cpx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "patchwork_ipv4" {
  server_id  = hcloud_server.patchwork.id
  ip_address = hcloud_server.patchwork.ipv4_address
  dns_ptr    = "patchwork.archlinux.org"
}

resource "hcloud_rdns" "patchwork_ipv6" {
  server_id  = hcloud_server.patchwork.id
  ip_address = hcloud_server.patchwork.ipv6_address
  dns_ptr    = "patchwork.archlinux.org"
}

resource "hcloud_server" "patchwork" {
  name        = "patchwork.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "security_ipv4" {
  server_id  = hcloud_server.security.id
  ip_address = hcloud_server.security.ipv4_address
  dns_ptr    = "security.archlinux.org"
}

resource "hcloud_rdns" "security_ipv6" {
  server_id  = hcloud_server.security.id
  ip_address = hcloud_server.security.ipv6_address
  dns_ptr    = "security.archlinux.org"
}

resource "hcloud_server" "security" {
  name        = "security.archlinux.org"
  image       = data.hcloud_image.archlinux.id
  server_type = "cx11"
  lifecycle {
    ignore_changes = [image]
  }
}
