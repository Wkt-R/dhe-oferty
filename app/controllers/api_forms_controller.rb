class ApiFormsController < ApplicationController
  def index
    @api_data = WebflowService.get_custom_fields
  end

  def edit
    # Log the ID to make sure it's being passed correctly
    Rails.logger.debug("Fetching item with ID: #{params[:id]}")

    @item = WebflowService.get_custom_fields.find { |i| i[:id] == params[:id] }

    # Log @item to verify it's being set correctly
    Rails.logger.debug("Fetched item: #{@item}")

    if @item.nil?
      flash[:alert] = "Item not found"
      redirect_to api_forms_path
    end
  end

  def update
    Rails.logger.debug("Updating item with ID: #{params[:id]}")

    if params[:id].blank?
      flash[:alert] = "Nie udalo sie zaladowac przedmiotow"
      redirect_to api_forms_path and return
    end

    updated_data = {
      stanowisko: params[:stanowisko],
      lokalizacja: params[:lokalizacja],
      opis: params[:opis],
      wymagania: params[:wymagania],
      aktywne: params[:aktywne] == "1" # Convert checkbox to boolean
    }

    result = WebflowService.update_item(params[:id], updated_data)

    if result[:success]
      flash[:notice] = "Zapisano"
      redirect_to api_forms_path
    else
      flash[:alert] = "Problem: #{result[:error]}"
      render :edit
    end
  end

  def new
    @item = {} # Empty hash to initialize the new form
  end

  def create
    # Collect form data, including 'name' field
    new_data = {
      stanowisko: params[:stanowisko],
      lokalizacja: params[:lokalizacja],
      opis: params[:opis],
      wymagania: params[:wymagania],
      aktywne: params[:aktywne] == "1", # Convert checkbox to boolean
      name: params[:stanowisko]  # Make sure 'name' is passed
    }

    # Call the WebflowService to create the item
    result = WebflowService.create_item(new_data)

    # Handle the response and redirect accordingly
    if result[:success]
      flash[:notice] = "Item created successfully."
      redirect_to api_forms_path
    else
      flash[:alert] = "Error: #{result[:error]}"
      render :new
    end
  end
end
