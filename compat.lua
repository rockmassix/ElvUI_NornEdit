-- Basic compatibility shims for retail/classic API name differences

if not IsAddOnLoaded then
  function IsAddOnLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
      return C_AddOns.IsAddOnLoaded(name)
    end
    return false
  end
end

if not GetAddOnMetadata then
  function GetAddOnMetadata(name, field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
      return C_AddOns.GetAddOnMetadata(name, field)
    end
    return nil
  end
end


