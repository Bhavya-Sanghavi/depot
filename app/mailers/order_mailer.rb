class OrderMailer < ApplicationMailer
  default from: 'Sam Ruby <depot@example.com>'

  def received(order)
    @order = order

    order.line_items.each do |line_item|
      images = line_item.product.images

      next unless images.attached?

      images.drop(1).each do |image|
        attachments[image.filename.to_s] = image.download
      end
    end

    I18n.with_locale(order.user&.language || 'en') do
      mail to: order.email, subject: t('order_mailer.received.subject')
    end
  end

  def shipped(order)
    @order = order

    mail to: order.email, subject: 'Pragmatic Store Order Shipped'
  end

  def all_orders(user)
    @user = user
    @orders = user.orders.includes(line_items: :product)

    I18n.with_locale(user.language || 'en') do
      mail(to: user.email, subject: t('order_mailer.all_orders.subject'))
    end
  end
end
