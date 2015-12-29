class ContactsController < ApplicationController
  # Create a new contact
  #
  # POST /visit/:visit_id/contacts
  def create
    @visit = Visit.find(params[:visit_id])
    @comment = @visit.contacts.create(contact_params)
    redirect_to visit_path(@visit)
  end

  # Destroy a contact
  #
  # DELETE /visit/:visit_id/contacts/:id
  def destroy
    @visit = Visit.find(params[:visit_id])
    @contact = @visit.contacts.find(params[:id])
    @contact.destroy
    redirect_to visit_path(@visit)
  end

  private
  def contact_params
    params.require(:contact).permit(:value, :info)
  end
end
