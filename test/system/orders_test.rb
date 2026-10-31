require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "check dynamic fields" do
    visit store_index_url(locale: :es)

    click_on "Añadir al Carrito", match: :first

    click_on "Comprar"

    assert_selector "fieldset[data-type='Check'][hidden]", visible: :all
    assert_selector "fieldset[data-type='Credit card'][hidden]", visible: :all
    assert_selector "fieldset[data-type='Purchase order'][hidden]", visible: :all

    select "Cheque", from: "Forma de pago"

    assert_selector "fieldset[data-type='Check']:not([hidden]) #order_routing_number"
    assert_selector "fieldset[data-type='Check']:not([hidden]) #order_account_number"
    assert_selector "fieldset[data-type='Credit card'][hidden]", visible: :all
    assert_selector "fieldset[data-type='Purchase order'][hidden]", visible: :all

    select "Tarjeta de Crédito", from: "Forma de pago"

    assert_selector "fieldset[data-type='Check'][hidden]", visible: :all
    assert_selector "fieldset[data-type='Credit card']:not([hidden]) #order_credit_card_number"
    assert_selector "fieldset[data-type='Credit card']:not([hidden]) #order_expiration_date"
    assert_selector "fieldset[data-type='Purchase order'][hidden]", visible: :all

    select "Orden de Compra", from: "Forma de pago"

    assert_selector "fieldset[data-type='Check'][hidden]", visible: :all
    assert_selector "fieldset[data-type='Credit card'][hidden]", visible: :all
    assert_selector "fieldset[data-type='Purchase order']:not([hidden]) #order_po_number"
  end

  test "check order and delivery" do
    LineItem.delete_all
    Order.delete_all

    visit store_index_url(locale: :es)

    click_on "Añadir al Carrito", match: :first

    click_on "Comprar"

    fill_in "Nombre", with: "Dave Thomas"
    fill_in "Dirección", with: "123 Main Street"
    fill_in "E-mail", with: "dave@example.com"

    select "Cheque", from: "Forma de pago"
    fill_in "order_routing_number", with: "123456"
    fill_in "order_account_number", with: "987654"

    click_button "Realizar Pedido"
    assert_text "Gracias por su pedido"

    perform_enqueued_jobs
    perform_enqueued_jobs
    assert_performed_jobs 2

    orders = Order.all
    assert_equal 1, orders.size

    order = orders.first
    assert_equal "Dave Thomas",      order.name
    assert_equal "123 Main Street",  order.address
    assert_equal "dave@example.com", order.email
    assert_equal "Check",            order.pay_type
    assert_equal 1, order.line_items.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "dave@example.com" ],                 mail.to
    assert_equal "Sam Ruby <depot@example.com>",       mail[:from].value
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end
end
