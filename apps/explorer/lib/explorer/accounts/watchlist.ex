defmodule Explorer.Accounts.Watchlist do
  use Ecto.Schema
  import Ecto.Changeset
  alias Explorer.Accounts.Identity
  alias Explorer.Accounts.WatchlistAddress

  schema "account_watchlists" do
    field(:name, :string)
    belongs_to(:identity, Identity)
    has_many(:watchlist_addresses, WatchlistAddress)

    timestamps()
  end

  @doc false
  def changeset(watchlist, attrs) do
    watchlist
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
