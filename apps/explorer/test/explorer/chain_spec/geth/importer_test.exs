defmodule Explorer.ChainSpec.Geth.ImporterTest do
  use Explorer.DataCase

  import Mox
  import EthereumJSONRPC, only: [integer_to_quantity: 1]

  alias Explorer.Chain.Address.{CoinBalance, CoinBalanceDaily}
  alias Explorer.Chain.{Address, Hash}
  alias Explorer.ChainSpec.Geth.Importer
  alias Explorer.Repo

  setup :set_mox_global

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Explorer.Repo, :auto)

    on_exit(fn ->
      clear_db()
    end)

    :ok
  end

  @genesis "#{File.cwd!()}/test/support/fixture/chain_spec/qdai_genesis.json"
           |> File.read!()
           |> Jason.decode!()

  describe "genesis_accounts/1" do
    test "parses coin balance and contract code" do
      coin_balances = Importer.genesis_accounts(@genesis)

      assert Enum.count(coin_balances) == 3

      assert %{
               address_hash: %Hash{
                 byte_count: 20,
                 bytes: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 254>>
               },
               value: 0,
               contract_code:
                 "0x6080604052600436106100cf5763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630f3a053381146100d457806310f2ee7c146101075780632ee57f8d1461011c57806330f6eb16146101665780633d84b8c11461018a5780634476d66a146101ab578063553a5c85146101c3578063899ca7fc146101d8578063aa9fa27414610225578063b4a523e81461024b578063db456f771461026c578063e73b9e2f146102a0578063efdc4d01146102c1578063f91c2898146102d6575b600080fd5b3480156100e057600080fd5b506100f5600160a060020a036004351661039b565b60408051918252519081900360200190f35b34801561011357600080fd5b506100f5610464565b34801561012857600080fd5b50610131610469565b604080517fffffffff000000000000000000000000000000000000000000000000000000009092168252519081900360200190f35b34801561017257600080fd5b506100f5600160a060020a036004351660243561049e565b34801561019657600080fd5b506100f5600160a060020a0360043516610570565b3480156101b757600080fd5b506100f56004356105f7565b3480156101cf57600080fd5b506100f561066f565b3480156101e457600080fd5b506101ed6106bd565b6040518082602080838360005b838110156102125781810151838201526020016101fa565b5050505090500191505060405180910390f35b34801561023157600080fd5b50610249600435600160a060020a03602435166106eb565b005b34801561025757600080fd5b506100f5600160a060020a03600435166107bd565b34801561027857600080fd5b50610284600435610844565b60408051600160a060020a039092168252519081900360200190f35b3480156102ac57600080fd5b506100f5600160a060020a0360043516610908565b3480156102cd57600080fd5b506100f561098f565b3480156102e257600080fd5b5061030260246004803582810192908201359181359182019101356109dd565b604051808060200180602001838103835285818151815260200191508051906020019060200280838360005b8381101561034657818101518382015260200161032e565b50505050905001838103825284818151815260200191508051906020019060200280838360005b8381101561038557818101518382015260200161036d565b5050505090500194505050505060405180910390f35b604080517f0f09dbb26898a3af738d25c5fff308337ac8f2b0acbbaf209b373fb1389bcf2f602080830191909152606060020a600160a060020a038516028284015282516034818403018152605490920192839052815160009384938493909282918401908083835b602083106104235780518252601f199092019160209182019101610404565b51815160209384036101000a600019018019909216911617905260408051929094018290039091208652850195909552929092016000205495945050505050565b600181565b604080517f626c6f636b5265776172640000000000000000000000000000000000000000008152905190819003600b01902090565b604080517f24ae442c1f305c4f1294bf2dddd491a64250b2818b446706e9a74aeaaaf6f419602080830191909152606060020a600160a060020a0386160282840152605480830185905283518084039091018152607490920192839052815160009384938493909282918401908083835b6020831061052e5780518252601f19909201916020918201910161050f565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120865285019590955292909201600020549695505050505050565b604080517f0fd3be07b1332be84678873bf53feb10604cd09244fb4bb9154e03e00709b9e7602080830191909152606060020a600160a060020a03851602828401528251603481840301815260549092019283905281516000938493849390928291840190808383602083106104235780518252601f199092019160209182019101610404565b604080517f3840e646f7ce9b3210f5440e2dbd6b36451169bfdac65ef00a161729eded81bd60208083019190915281830184905282518083038401815260609092019283905281516000938493849390928291840190808383602083106104235780518252601f199092019160209182019101610404565b7f076e79ca1c3a46f0c7d1e9e7f14bcb9716bfc49eed37baf510328301a7109c2560009081526020527fec9588bd3242595c0e33049f6384a658ee56f04f9b9e85c6cc9a045c4948c9515490565b6106c56112f3565b50604080516020810190915273bf3d6f830ce263cae987193982192cd990442b53815290565b60006106f633610baf565b151561070157600080fd5b82151561070d57600080fd5b600160a060020a038216151561072257600080fd5b61072b8261039b565b905080151561073d5761073d82610c1a565b610756610750828563ffffffff610d5716565b83610d6a565b6107786107728461076633610908565b9063ffffffff610d5716565b33610e34565b6040805184815290513391600160a060020a038516917f3c798bbcf33115b42c728b8504cff11dd58736e9fa789f1cda2738db7d696b2a9181900360200190a3505050565b604080517f12e71282a577e2b463da2c18bc96b6122db29bcef9065ed5a7f0f9316c11c08e602080830191909152606060020a600160a060020a03851602828401528251603481840301815260549092019283905281516000938493849390928291840190808383602083106104235780518252601f199092019160209182019101610404565b604080517fa47da669ec9f3749fbb12db00588b5fa6b5bbd24da81eb6cab44261334c21c1760208083019190915281830184905282518083038401815260609092019283905281516000936002938593909282918401908083835b602083106108be5780518252601f19909201916020918201910161089f565b51815160209384036101000a6000190180199092169116179052604080519290940182900390912086528501959095529290920160002054600160a060020a031695945050505050565b604080517fa7f48dc57b1a051b1732e5ed136bbfd33bb5aa418e3e3498901320529e785461602080830191909152606060020a600160a060020a03851602828401528251603481840301815260549092019283905281516000938493849390928291840190808383602083106104235780518252601f199092019160209182019101610404565b7f0678259008a66390de8a5ac3f500d1dfb0d0f57018441e2cc69aaa0f52c97d4460009081526020527f3f9dbe5402519a8ea505664ae3f65100b338acc0e57c0abec1fcff383511ac4f5490565b60608060008180828080808033156109f457600080fd5b8c156109ff57600080fd5b8a15610a0a57600080fd5b610a1261098f565b975087604051908082528060200260200182016040528015610a3e578160200160208202803883390190505b50965087604051908082528060200260200182016040528015610a6b578160200160208202803883390190505b509550600094505b87851015610ae757610a8485610844565b9350610a8f8461039b565b9250610a9c600085610d6a565b838786815181101515610aab57fe5b600160a060020a0390921660209283029091019091015285518390879087908110610ad257fe5b60209081029091010152600190940193610a73565b600094505b87851015610b3757610b2c8686815181101515610b0557fe5b906020019060200201518887815181101515610b1d57fe5b90602001906020020151610ebb565b600190940193610aec565b600094505b6001851015610b9357610b4d6106bd565b8560018110610b5857fe5b60200201519150610b6882610908565b90506000811115610b8857610b7e600083610e34565b610b8881836111c4565b600190940193610b3c565b610b9b6112a4565b50949c939b50929950505050505050505050565b6000610bb96112f3565b6000610bc36106bd565b9150600090505b6001811015610c0e57818160018110610bdf57fe5b6020020151600160a060020a031684600160a060020a03161415610c065760019250610c13565b600101610bca565b600092505b5050919050565b6000610c2461098f565b604080517fa47da669ec9f3749fbb12db00588b5fa6b5bbd24da81eb6cab44261334c21c176020808301919091528183018490528251808303840181526060909201928390528151939450859360029360009392909182918401908083835b60208310610ca25780518252601f199092019160209182019101610c83565b51815160209384036101000a6000190180199092169116179052604080519290940182900390912086528581019690965250929092016000908120805473ffffffffffffffffffffffffffffffffffffffff1916600160a060020a03969096169590951790945550507f0678259008a66390de8a5ac3f500d1dfb0d0f57018441e2cc69aaa0f52c97d448252526001017f3f9dbe5402519a8ea505664ae3f65100b338acc0e57c0abec1fcff383511ac4f5550565b81810182811015610d6457fe5b92915050565b604080517f0f09dbb26898a3af738d25c5fff308337ac8f2b0acbbaf209b373fb1389bcf2f602080830191909152606060020a600160a060020a038516028284015282516034818403018152605490920192839052815185936000938493909282918401908083835b60208310610df25780518252601f199092019160209182019101610dd3565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120865285019590955292909201600020939093555050505050565b604080517fa7f48dc57b1a051b1732e5ed136bbfd33bb5aa418e3e3498901320529e785461602080830191909152606060020a600160a060020a0385160282840152825160348184030181526054909201928390528151859360009384939092829184019080838360208310610df25780518252601f199092019160209182019101610dd3565b604080517f24ae442c1f305c4f1294bf2dddd491a64250b2818b446706e9a74aeaaaf6f419602080830191909152606060020a600160a060020a038516028284015243605480840191909152835180840390910181526074909201928390528151600093918291908401908083835b60208310610f495780518252601f199092019160209182019101610f2a565b51815160209384036101000a60001901801990921691161790526040805192909401829003822060008181528083528590208a90557f0fd3be07b1332be84678873bf53feb10604cd09244fb4bb9154e03e00709b9e783830152600160a060020a038916606060020a02838601528451808403603401815260549093019485905282519097509195509293508392850191508083835b60208310610ffe5780518252601f199092019160209182019101610fdf565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120600081815291829052929020549194506110469350909150859050610d57565b600082815260208181526040918290209290925580517f3840e646f7ce9b3210f5440e2dbd6b36451169bfdac65ef00a161729eded81bd818401524381830152815180820383018152606090910191829052805190928291908401908083835b602083106110c55780518252601f1990920191602091820191016110a6565b51815160209384036101000a600019018019909216911617905260408051929094018290039091206000818152918290529290205491945061110d9350909150859050610d57565b6000828152602081905260408120919091557f076e79ca1c3a46f0c7d1e9e7f14bcb9716bfc49eed37baf510328301a7109c2590527fec9588bd3242595c0e33049f6384a658ee56f04f9b9e85c6cc9a045c4948c95154611174908463ffffffff610d5716565b7f076e79ca1c3a46f0c7d1e9e7f14bcb9716bfc49eed37baf510328301a7109c2560009081526020527fec9588bd3242595c0e33049f6384a658ee56f04f9b9e85c6cc9a045c4948c95155505050565b604080517f12e71282a577e2b463da2c18bc96b6122db29bcef9065ed5a7f0f9316c11c08e602080830191909152606060020a600160a060020a0385160282840152825160348184030181526054909201928390528151600093918291908401908083835b602083106112485780518252601f199092019160209182019101611229565b51815160209384036101000a60001901801990921691161790526040805192909401829003909120600081815291829052929020549194506112909350909150859050610d57565b600091825260208290526040909120555050565b7f0678259008a66390de8a5ac3f500d1dfb0d0f57018441e2cc69aaa0f52c97d44600090815260208190527f3f9dbe5402519a8ea505664ae3f65100b338acc0e57c0abec1fcff383511ac4f55565b60206040519081016040528060019060208202803883395091929150505600a165627a7a7230582053b0e89d867fc0c586739f4911c11be5aaee046320d1dff0da51c1b04404b4a00029"
             } ==
               List.first(coin_balances)
    end
  end

  describe "import_genesis_accounts/1" do
    test "imports accounts" do
      block_quantity = integer_to_quantity(1)
      res = eth_block_number_fake_response(block_quantity)

      EthereumJSONRPC.Mox
      |> expect(:json_rpc, fn [
                                %{id: 0, jsonrpc: "2.0", method: "eth_getBlockByNumber", params: ["0x1", true]}
                              ],
                              _ ->
        {:ok, [res]}
      end)

      {:ok, %{address_coin_balances: address_coin_balances}} = Importer.import_genesis_accounts(@genesis)

      assert Enum.count(address_coin_balances) == 3
      assert CoinBalance |> Repo.all() |> Enum.count() == 3
      assert CoinBalanceDaily |> Repo.all() |> Enum.count() == 3
      assert Address |> Repo.all() |> Enum.count() == 3
    end

    test "imports contract code" do
      block_quantity = integer_to_quantity(1)
      res = eth_block_number_fake_response(block_quantity)

      EthereumJSONRPC.Mox
      |> expect(:json_rpc, fn [
                                %{id: 0, jsonrpc: "2.0", method: "eth_getBlockByNumber", params: ["0x1", true]}
                              ],
                              [] ->
        {:ok, [res]}
      end)

      code =
        "0x608060405234801561001057600080fd5b50600436106100cf5760003560e01c806391ad27b41161008c57806398d5fdca1161006657806398d5fdca14610262578063a97e5c9314610280578063df5dd1a5146102dc578063eebd48b014610320576100cf565b806391ad27b4146101e457806391b7f5ed14610202578063955d14cd14610244576100cf565b80630aa6f2fe146100d457806320ba81ee1461011657806322a90082146101345780634c2c987c14610176578063764cbcd1146101985780637837efdc146101da575b600080fd5b610100600480360360208110156100ea57600080fd5b8101908080359060200190929190505050610353565b6040518082815260200191505060405180910390f35b61011e6103c4565b6040518082815260200191505060405180910390f35b6101606004803603602081101561014a57600080fd5b81019080803590602001909291905050506103ce565b6040518082815260200191505060405180910390f35b61017e61043f565b604051808215151515815260200191505060405180910390f35b6101c4600480360360208110156101ae57600080fd5b8101908080359060200190929190505050610456565b6040518082815260200191505060405180910390f35b6101e26104c7565b005b6101ec6104d2565b6040518082815260200191505060405180910390f35b61022e6004803603602081101561021857600080fd5b81019080803590602001909291905050506104dc565b6040518082815260200191505060405180910390f35b61024c6106a2565b6040518082815260200191505060405180910390f35b61026a6106ac565b6040518082815260200191505060405180910390f35b6102c26004803603602081101561029657600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506106b6565b604051808215151515815260200191505060405180910390f35b61031e600480360360208110156102f257600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506106d3565b005b61032861073d565b6040518085815260200184815260200183815260200182815260200194505050505060405180910390f35b600061035e336106b6565b6103b3576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526030815260200180610b4f6030913960400191505060405180910390fd5b816004819055506004549050919050565b6000600454905090565b60006103d9336106b6565b61042e576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526030815260200180610b4f6030913960400191505060405180910390fd5b816003819055506003549050919050565b6000600560009054906101000a900460ff16905090565b6000610461336106b6565b6104b6576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526030815260200180610b4f6030913960400191505060405180910390fd5b816002819055506002549050919050565b6104d033610771565b565b6000600354905090565b60006104e7336106b6565b61053c576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526030815260200180610b4f6030913960400191505060405180910390fd5b600082116105b2576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260098152602001807f7072696365203c3d30000000000000000000000000000000000000000000000081525060200191505060405180910390fd5b6105ba6104d2565b6105c26106a2565b01421015610638576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260148152602001807f54494d455f4c4f434b5f494e434f4d504c45544500000000000000000000000081525060200191505060405180910390fd5b610641826107cb565b5061064b42610456565b503373ffffffffffffffffffffffffffffffffffffffff167f95dce27040c59c8b1c445b284f81a3aaae6eecd7d08d5c7684faee64cdb514a1836040518082815260200191505060405180910390a2819050919050565b6000600254905090565b6000600154905090565b60006106cc82600061083c90919063ffffffff16565b9050919050565b6106dc336106b6565b610731576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526030815260200180610b4f6030913960400191505060405180910390fd5b61073a8161091a565b50565b60008060008061074b6106ac565b6107536104d2565b61075b6103c4565b6107636106a2565b935093509350935090919293565b61078581600061097390919063ffffffff16565b8073ffffffffffffffffffffffffffffffffffffffff167f9c8e7d83025bef8a04c664b2f753f64b8814bdb7e27291d7e50935f18cc3c71260405160405180910390a250565b60006107d6336106b6565b61082b576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526030815260200180610b4f6030913960400191505060405180910390fd5b816001819055506001549050919050565b60008073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff1614156108c3576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526022815260200180610b2d6022913960400191505060405180910390fd5b8260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16905092915050565b61092e816000610a3090919063ffffffff16565b8073ffffffffffffffffffffffffffffffffffffffff167e47706786c922d17b39285dc59d696bafea72c0b003d3841ae1202076f4c2e460405160405180910390a250565b61097d828261083c565b6109d2576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401808060200182810382526021815260200180610b0c6021913960400191505060405180910390fd5b60008260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055505050565b610a3a828261083c565b15610aad576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601f8152602001807f526f6c65733a206163636f756e7420616c72656164792068617320726f6c650081525060200191505060405180910390fd5b60018260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff021916908315150217905550505056fe526f6c65733a206163636f756e7420646f6573206e6f74206861766520726f6c65526f6c65733a206163636f756e7420697320746865207a65726f20616464726573734f7261636c65526f6c653a2063616c6c657220646f6573206e6f74206861766520746865204f7261636c6520726f6c65a265627a7a72315820df30730da57a5061c487e0b37e84e80308fa443e2e80ee9117a13fa8149caf4164736f6c634300050b0032"

      chain_spec = %{
        "alloc" => %{
          "0xcd59f3dde77e09940befb6ee58031965cae7a336" => %{
            "balance" => "0x21e19e0c9bab2400000",
            "code" => code
          }
        }
      }

      {:ok, _} = Importer.import_genesis_accounts(chain_spec)

      address = Address |> Repo.one()

      assert to_string(address.contract_code) == code
    end

    test "imports coin balances without 0x" do
      block_quantity = integer_to_quantity(1)
      res = eth_block_number_fake_response(block_quantity)

      EthereumJSONRPC.Mox
      |> expect(:json_rpc, fn [
                                %{id: 0, jsonrpc: "2.0", method: "eth_getBlockByNumber", params: ["0x1", true]}
                              ],
                              [] ->
        {:ok, [res]}
      end)

      {:ok, %{address_coin_balances: address_coin_balances}} = Importer.import_genesis_accounts(@genesis)

      assert Enum.count(address_coin_balances) == 3
      assert CoinBalance |> Repo.all() |> Enum.count() == 3
      assert CoinBalanceDaily |> Repo.all() |> Enum.count() == 3
      assert Address |> Repo.all() |> Enum.count() == 3
    end
  end

  defp eth_block_number_fake_response(block_quantity) do
    %{
      id: 0,
      jsonrpc: "2.0",
      result: %{
        "author" => "0x0000000000000000000000000000000000000000",
        "difficulty" => "0x20000",
        "extraData" => "0x",
        "gasLimit" => "0x663be0",
        "gasUsed" => "0x0",
        "hash" => "0x5b28c1bfd3a15230c9a46b399cd0f9a6920d432e85381cc6a140b06e8410112f",
        "logsBloom" =>
          "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        "miner" => "0x0000000000000000000000000000000000000000",
        "number" => block_quantity,
        "parentHash" => "0x0000000000000000000000000000000000000000000000000000000000000000",
        "receiptsRoot" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
        "sealFields" => [
          "0x80",
          "0xb8410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        ],
        "sha3Uncles" => "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
        "signature" =>
          "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        "size" => "0x215",
        "stateRoot" => "0xfad4af258fd11939fae0c6c6eec9d340b1caac0b0196fd9a1bc3f489c5bf00b3",
        "step" => "0",
        "timestamp" => "0x0",
        "totalDifficulty" => "0x20000",
        "transactions" => [],
        "transactionsRoot" => "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
        "uncles" => []
      }
    }
  end
end
