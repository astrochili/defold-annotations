return {
  ["elements.sys.get_application_info.returnvalues.app_info.types.table"] = "{ installed:boolean }",
  ["elements.sys.get_connectivity.returnvalues.status.types.constant"] = "sys.NETWORK",
  ["elements.sys.get_engine_info.returnvalues.engine_info.types.table"] = "{ version:string, version_sha1:string, is_debug:boolean }",
  ["elements.sys.get_ifaddrs.returnvalues.ifaddrs.types.table"] = "{ name:string, address?:string, mac?:string, up:boolean, running:boolean }",
  ["elements.sys.get_sys_info.parameters.options.types.table"] = "{ ignore_secure?:boolean }",
  ["elements.sys.get_sys_info.returnvalues.sys_info.types.table"] = "{ device_model?:string, manufacturer?:string, system_name:string, system_version:string, api_version:string, language:string, device_language:string, territory:string, gmt_offset:number, device_ident?:string, user_agent?:string }",
  ["elements.sys.open_url.parameters.attributes.types.table"] = "{ target?:string, name?:string }",
}
