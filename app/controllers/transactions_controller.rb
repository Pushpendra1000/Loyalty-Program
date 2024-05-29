# frozen_string_literal: true

# TransactionsController
class TransactionsController < ApplicationController
  before_action :fetch_transaction, only: :show

  def index
    render_success_response(
      { transaction: array_serializer.new(@current_user.transactions,
                                          serializer: TransactionSerializer) }, I18n.t('transaction.list')
    )
  end

  def create
    transaction = @current_user.transactions.build(transaction_params)

    if transaction.save
      render_success_response({ transaction: single_serializer.new(transaction, serializer: TransactionSerializer) },
                              I18n.t('transaction.create'), 201)
    else
      render_unprocessable_entity_response(transaction)
    end
  end

  def show
    render_success_response({ transaction: single_serializer.new(@transaction, serializer: TransactionSerializer) },
                            I18n.t('transaction.show'))
  end

  private

  def transaction_params
    params.permit(:amount, :currency)
  end

  def fetch_transaction
    @transaction = @current_user.transactions.find(params[:id])
  end
end
