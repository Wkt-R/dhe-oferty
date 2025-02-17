class WebflowService
  BASE_URL = "https://api.webflow.com/v2"
  API_TOKEN = ENV["WEBFLOW_API_TOKEN"]
  COLLECTION_ID = "67ad9d254e168b338b4e4a9b"

  def self.get_custom_fields
    uri = URI("#{BASE_URL}/collections/#{COLLECTION_ID}/items")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{API_TOKEN}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    Rails.logger.debug("Webflow API Response: #{response.body}")
    Rails.logger.debug("Response Status: #{response.code}")

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      items = data["items"].map do |item|
        {
          id: item["id"],
          stanowisko: item["fieldData"]["stanowisko"],
          lokalizacja: item["fieldData"]["lokalizacja"],
          opis: item["fieldData"]["opis-i-wymagania"],
          wymagania: item["fieldData"]["wymagania2"],
          aktywne: item["fieldData"]["aktywne-2"]
        }
      end
      items
    else
      { error: "Failed to fetch data from Webflow: #{response.body}" }
    end
  end

  def self.update_item(item_id, updated_data)
    uri = URI("#{BASE_URL}/collections/#{COLLECTION_ID}/items/#{item_id}")
    request = Net::HTTP::Patch.new(uri)
    request["Authorization"] = "Bearer #{API_TOKEN}"
    request["Content-Type"] = "application/json"

    request.body = {
      fieldData: {
        "stanowisko" => updated_data[:stanowisko],
        "lokalizacja" => updated_data[:lokalizacja],
        "opis-i-wymagania" => updated_data[:opis],
        "wymagania2" => updated_data[:wymagania],
        "aktywne-2" => updated_data[:aktywne]
      }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    Rails.logger.debug("Webflow API Update Response: #{response.body}")

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      item_id = data["id"]
      publish_item(COLLECTION_ID, item_id)
      { success: true, item_id: item_id }
    else
      { success: false, error: response.body }
    end
  end

  def self.create_item(new_data)
    uri = URI("#{BASE_URL}/collections/#{COLLECTION_ID}/items")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{API_TOKEN}"
    request["Content-Type"] = "application/json"

    request.body = {
      "items" => [
        {
          "fieldData" => {
            "name" => new_data[:stanowisko],
            "stanowisko" => new_data[:stanowisko],
            "lokalizacja" => new_data[:lokalizacja],
            "opis-i-wymagania" => new_data[:opis],
            "wymagania2" => new_data[:wymagania],
            "aktywne-2" => new_data[:aktywne]
          }
        }
      ]
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      item_id = data["items"].first["id"]  # Get the ID of the newly created item
      publish_item(COLLECTION_ID, item_id) # Publish the item immediately after creation
      { success: true, item_id: item_id }
    else
      { success: false, error: response.body }
    end
  end

  def self.publish_item(collection_id, item_id)
    uri = URI("https://api.webflow.com/collections/#{collection_id}/items/#{item_id}/publish")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{API_TOKEN}"
    request["Content-Type"] = "application/json"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    Rails.logger.debug("Webflow API Publish Item Response: #{response.body}")
    Rails.logger.debug("Publish Item Response Status: #{response.code}")

    if response.is_a?(Net::HTTPSuccess)
      { success: true }
    else
      error_message = begin
                         JSON.parse(response.body)["msg"] || response.body
                       rescue
                         response.body
                       end
      Rails.logger.error("Publish failed: #{error_message}")
      { success: false, error: error_message }
    end
  end
end
