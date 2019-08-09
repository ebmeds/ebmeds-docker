def register(params)
  @source = params["source"]
end

# Move reminder properties to the root-level
def filter(event)
  # tag @source_field_not_found when source fields is not present
  if event.get(@source).nil?
    event.tag("#{@source}_not_found")
    return [event]
  end

  event
    .get(@source)
    .each do |k, v|
      event.set(k, v)
    end

  # Logstash required filter method to return a list of events.
  return [event]
end
