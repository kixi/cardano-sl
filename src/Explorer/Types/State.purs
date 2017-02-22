module Explorer.Types.State where

import Explorer.I18n.Lang (Language)
import Explorer.Routes (Route)
import Pos.Explorer.Web.ClientTypes (CBlockEntry, CTxEntry)
import Prelude (class Eq, class Ord)

-- Add all State types here to generate lenses from it

type State =
    { lang :: Language
    , route :: Route
    , socket :: SocketState
    , viewStates :: ViewStates
    , latestBlocks :: CBlockEntries
    , latestTransactions :: CTxEntries
    , errors :: Errors
    , loading :: Boolean
    }

type SocketState =
    { connected :: Boolean
    }

data DashboardAPICode = Curl | Node | JQuery

derive instance eqDashboardAPICode :: Eq DashboardAPICode
derive instance ordDashboardAPICode :: Ord DashboardAPICode

type CBlockEntries = Array CBlockEntry
type CTxEntries = Array CTxEntry

type Errors = Array String

type ViewStates =
    { dashboard :: DashboardViewState
    , addressDetail :: AddressDetailViewState
    , blockDetail :: BlockDetailViewState
    }

type DashboardViewState =
    { blocksExpanded :: Boolean
    , dashboardBlockPagination :: Int
    , transactionsExpanded :: Boolean
    , selectedApiCode :: DashboardAPICode
    , searchInput :: Boolean
    }

type BlockDetailViewState =
    { blockTxPagination :: Int
    }

type AddressDetailViewState =
    { addressTxPagination :: Int
    }

-- TODO (jk) CCurrency should be generated by purescript-bridge later
data CCurrency =
      ADA
    | BTC
    | USD
