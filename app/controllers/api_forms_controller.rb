class ApiFormsController < ApplicationController
  def index
    @api_data = WebflowService.get_custom_fields
  end

  def edit
    Rails.logger.debug("Fetching item with ID: #{params[:id]}")
    @item = WebflowService.get_custom_fields.find { |i| i[:id] == params[:id] }
    Rails.logger.debug("Fetched item: #{@item}")
    if @item.nil?
      flash[:alert] = "Item not found"
      redirect_to api_forms_path
    end
  end

  def update
    Rails.logger.debug("Updating item with ID: #{params[:id]}")
    if params[:id].blank?
      flash[:alert] = "Couldn't find the item you're trying to edit"
      redirect_to api_forms_path and return
    end

    updated_data = {
      stanowisko: params[:stanowisko],
      lokalizacja: params[:lokalizacja],
      opis: params[:opis],
      wymagania: params[:wymagania],
      aktywne: params[:aktywne] == "1"
    }

    # Update the item
    result = WebflowService.update_item(params[:id], updated_data)

    if result[:success]
      flash[:notice] = "Item saved and published"
      redirect_to api_forms_path
    else
      flash[:alert] = "Item saved but not published."
      render :edit
    end
  end

  def new
    @item = {}
  end

  def create
    new_data = {
      stanowisko: params[:stanowisko],
      lokalizacja: params[:lokalizacja],
      opis: params[:opis],
      wymagania: params[:wymagania],
      aktywne: params[:aktywne] == "1",
      name: params[:stanowisko]
    }

    # Create the item
    result = WebflowService.create_item(new_data)

    if result[:success]
      flash[:notice] = "Item created and published successfully."
      redirect_to api_forms_path
    else
      flash[:alert] = "Error: #{result[:error]}"
      render :new
    end
  end
end
