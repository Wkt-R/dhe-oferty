# app/services/webflow_service.rb
require 'net/http'
require 'json'
require 'uri'

class WebflowService
  BASE_URL = "https://api.webflow.com/v2"
  API_TOKEN = ENV['WEBFLOW_API_TOKEN']  # Your Webflow API token
  COLLECTION_ID = "67ad9d254e168b338b4e4a9b"  # Your Webflow Collection ID

  def self.get_custom_fields
    uri = URI("#{BASE_URL}/collections/#{COLLECTION_ID}/items")
    
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{API_TOKEN}"

    # Perform the request and return the response
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
      return items
    else
      return { error: "Failed to fetch data from Webflow: #{response.body}" }
    end
  end

  def self.update_item(item_id, updated_data)
    uri = URI("#{BASE_URL}/collections/#{COLLECTION_ID}/items/#{item_id}")
    request = Net::HTTP::Patch.new(uri)
    request["Authorization"] = "Bearer #{API_TOKEN}"
    request["Content-Type"] = "application/json"

    # Map form fields to Webflow API fields
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
      { success: true }
    else
      { success: false, error: response.body }
    end
  end
end
