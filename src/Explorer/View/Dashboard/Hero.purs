module Explorer.View.Dashboard.Hero (heroView) where

import Prelude
import Data.Array (null, slice)
import Data.Lens ((^.))
import Data.Map (Map, fromFoldable, lookup, toAscUnfoldable) as M
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (unwrap)
import Data.Time.NominalDiffTime.Lenses (_NominalDiffTime)
import Data.Tuple (Tuple(..))
import Explorer.I18n.Lang (Language, translate)
import Explorer.I18n.Lenses (dbExploreTransactions, dbTotalAmountOfTransactions, dbTotalAmountOf, dbTotalSupply, cADA, dbPriceSince, dbPriceForOne, dbPriceAverage, dbLastBlocksDescription, cNetwork, dbNetworkDifficultyDescription, dbApiDescription, dbAboutBlockchain, dbAboutBlockchainDescription, dbAddressSearch, dbAddressSearchDescription, dbBlockchainOffer, dbBlockSearch, dbBlockSearchDescription, dbCurl, dbGetAddress, dbLastBlocks, dbGetApiKey, dbMoreExamples, dbJQuery, dbNode, dbNetworkDifficulty, dbResponse, dbTransactionSearch, dbTransactionSearchDescription, cApi, cCollapse, cNoData, cExpand, cTransactions, common, dashboard, hero, hrTitle, hrSearch, hrSubtitle, cTransactionFeed) as I18nL
import Explorer.Lenses.State (lang, latestTransactions, searchInput)
import Explorer.Routes (Route(..), toUrl)
import Explorer.Types.Actions (Action(..))
import Explorer.Types.State (CCurrency(..), DashboardAPICode(..), State, CTxEntries)
import Explorer.Util.String (substitute)
import Explorer.View.Common (currencyCSSClass)
import Explorer.View.Dashboard.Lenses (dashboardSelectedApiCode, dashboardTransactionsExpanded, dashboardViewState)
import Explorer.View.Dashboard.Shared (headerView)
import Explorer.View.Dashboard.Types (HeaderLink(..), HeaderOptions(..))
import Pos.Explorer.Web.ClientTypes (CTxEntry(..))
import Pos.Explorer.Web.Lenses.ClientTypes (cteId, cteAmount, cteTimeIssued, _CTxId, _CHash)
import Pos.Types.Lenses.Core (_Coin, getCoin)
import Pux.Html (Html, div, h3, text, h1, h2, input, h4, p, code) as P
import Pux.Html.Attributes (className, type_, placeholder, dangerouslySetInnerHTML) as P
import Pux.Html.Events (onClick, onFocus, onBlur) as P
import Pux.Router (link) as P

heroView :: State -> P.Html Action
heroView state =
    let
        searchInputFocused = state ^. (dashboardViewState <<< searchInput)
        focusedClazz = if searchInputFocused then " focused" else ""
        searchIconClazz = if searchInputFocused then " bg-icon-search-hover" else " bg-icon-search"
    in
    P.div
        [ P.className "explorer-dashboard__hero" ]
        [ P.div
            [ P.className "hero-container" ]
            [ P.h1
                [ P.className "hero-headline" ]
                [ P.text $ translate (I18nL.hero <<< I18nL.hrTitle) state.lang ]
            , P.h2
                [ P.className "hero-subheadline"]
                [ P.text $ translate (I18nL.hero <<< I18nL.hrSubtitle) state.lang ]
            , P.div
                [ P.className $ "hero-search-container" <> focusedClazz ]
                [ P.input
                    [ P.className $ "hero-input" <> focusedClazz
                      , P.type_ "text"
                      , P.placeholder $ if searchInputFocused
                                        then ""
                                        else translate (I18nL.hero <<< I18nL.hrSearch) state.lang
                      , P.onFocus <<< const $ DashboardFocusSearchInput true
                      , P.onBlur <<< const $ DashboardFocusSearchInput false ]
                    []
                , P.div
                    [ P.className $ "hero-search-btn" <> searchIconClazz <> focusedClazz
                    , P.onClick $ const DashboardSearch ]
                    []
                ]
            ]
        ]


-- network


-- FIXME (jk): just for now, will use later `real` ADTs
type NetworkItems = Array NetworkItem

-- FIXME (jk): just for now, will use later `real` ADTs
type NetworkItem =
    { headline :: String
    , subheadline :: String
    , description :: String
    }

networkItems :: Language -> NetworkItems
networkItems lang =
    let ada = translate (I18nL.common <<< I18nL.cADA) lang in
    [ { headline: translate (I18nL.dashboard <<< I18nL.dbLastBlocks) lang
      , subheadline: "123456"
      , description: flip substitute ["20.02.2017 17:51:00", "50"]
            $ translate (I18nL.dashboard <<< I18nL.dbLastBlocksDescription) lang
      }
    , { headline: translate (I18nL.dashboard <<< I18nL.dbNetworkDifficulty) lang
      , subheadline: "1,234,567,890.12"
      , description: translate (I18nL.dashboard <<< I18nL.dbNetworkDifficultyDescription) lang
      }
    , { headline: translate (I18nL.dashboard <<< I18nL.dbPriceAverage) lang
      , subheadline: flip substitute ["1,000,000$", ada]
            $ translate (I18nL.dashboard <<< I18nL.dbPriceForOne) lang
      , description: flip substitute ["20% more"]
            $ translate (I18nL.dashboard <<< I18nL.dbPriceSince) lang
      }
    , { headline: translate (I18nL.dashboard <<< I18nL.dbTotalSupply) lang
      , subheadline: flip substitute ["9,876,543,210 "] $ translate (I18nL.common <<< I18nL.cADA) lang
      , description: flip substitute [ada] $ translate (I18nL.dashboard <<< I18nL.dbTotalAmountOf) lang
      }
    , { headline: translate (I18nL.common <<< I18nL.cTransactions) lang
      , subheadline: "82,491,247,592,742,929"
      , description: translate (I18nL.dashboard <<< I18nL.dbTotalAmountOfTransactions) lang
      }
    ]


networkView :: State -> P.Html Action
networkView state =
    let lang' = state ^. lang in
    P.div
        [ P.className "explorer-dashboard__wrapper" ]
        [ P.div
          [ P.className "explorer-dashboard__container" ]
          [ P.h3
                [ P.className "headline"]
                [ P.text $ translate (I18nL.common <<< I18nL.cNetwork) lang' ]
          , P.div
                [ P.className "explorer-dashboard__teaser" ]
                <<< map (networkItem state) $ networkItems lang'
          ]
        ]

networkItem :: State -> NetworkItem -> P.Html Action
networkItem state item =
    P.div
        [ P.className "teaser-item" ]
        [ P.h3
            [ P.className "teaser-item__headline" ]
            [ P.text item.headline ]
        , P.h4
              [ P.className $ "teaser-item__subheadline" ]
              [ P.text item.subheadline ]
        , P.p
              [ P.className $ "teaser-item__description" ]
              [ P.text item.description ]
        ]

-- transactions

maxTransactionRows :: Int
maxTransactionRows = 10

minTransactionRows :: Int
minTransactionRows = 5

transactionsView :: State -> P.Html Action
transactionsView state =
    P.div
        [ P.className "explorer-dashboard__wrapper" ]
        [ P.div
          [ P.className "explorer-dashboard__container" ]
          [ headerView state headerOptions
          , P.div
              [ P.className $ "transactions__waiting" <> visibleWaitingClazz ]
              [ P.text $ translate (I18nL.common <<< I18nL.cNoData) lang' ]
          , P.div
              [ P.className $ "transactions__container" <> visibleTxClazz ]
              $ map (transactionRow state) $ transactions'
          , P.div
            [ P.className $ "transactions__footer" <> visibleTxClazz ]
            [ P.div
                [ P.className "btn-expand"
                , P.onClick <<< const <<< DashboardExpandTransactions $ not expanded ]
                [ P.text expandLabel]
            ]
          -- TODO (jk) For debugging only - has to be removed later
          , P.div
              [ P.className $ "btn-debug"
              , P.onClick $ const RequestLatestTransactions  ]
              [ P.text "#Debug txs" ]
          ]
        ]
    where
      lang' = state ^. lang
      expanded = state ^. dashboardTransactionsExpanded
      expandLabel = if expanded
          then translate (I18nL.common <<< I18nL.cCollapse) lang'
          else translate (I18nL.common <<< I18nL.cExpand) lang'
      headerOptions = HeaderOptions
          { headline: translate (I18nL.common <<< I18nL.cTransactionFeed) lang'
          , link: Just $ HeaderLink { label: translate (I18nL.dashboard <<< I18nL.dbExploreTransactions) lang'
                                    , action: NoOp
                                    }
          }
      transactions = state ^. latestTransactions
      noTransactions = null transactions
      visibleTxClazz = if noTransactions then " invisible" else ""
      visibleWaitingClazz = if not noTransactions then " invisible" else ""
      transactions' :: CTxEntries
      transactions' = if expanded
          then slice 0 maxTransactionRows transactions
          else slice 0 minTransactionRows transactions

transactionRow :: State -> CTxEntry -> P.Html Action
transactionRow state (CTxEntry entry) =
    let txId = entry ^. (cteId <<< _CTxId <<< _CHash) in
    P.div
        [ P.className "transactions__row" ]
        [ P.link (toUrl <<< Transaction $ entry ^. cteId <<< _CTxId)
              [ P.className "transactions__column hash" ]
              [ P.text $ entry ^. (cteId <<< _CTxId <<< _CHash) ]
        , transactionColumn (show <<< unwrap $ entry ^. (cteTimeIssued <<< _NominalDiffTime)) ""
        , transactionColumn (show $ entry ^. (cteAmount <<< _Coin <<< getCoin)) <<< currencyCSSClass $ Just ADA
        ]

transactionColumn :: String -> String -> P.Html Action
transactionColumn value clazzName =
    P.div
        [ P.className $ "transactions__column " <> clazzName ]
        [ P.text value ]


-- offer


-- FIXME (jk): just for now, will use later `real` ADTs
type OfferItems = Array OfferItem

-- FIXME (jk): just for now, will use later `real` ADTs
type OfferItem =
    { headline :: String
    , description :: String
    }

offerItems :: Language -> OfferItems
offerItems lang =
    [ { headline: translate (I18nL.dashboard <<< I18nL.dbBlockSearch) lang
      , description: translate (I18nL.dashboard <<< I18nL.dbBlockSearchDescription) lang
      }
    , { headline: translate (I18nL.dashboard <<< I18nL.dbAddressSearch) lang
      , description: translate (I18nL.dashboard <<< I18nL.dbAddressSearchDescription) lang
      }
    , { headline: translate (I18nL.dashboard <<< I18nL.dbTransactionSearch) lang
      , description: translate (I18nL.dashboard <<< I18nL.dbTransactionSearchDescription) lang
      }
    , { headline: translate (I18nL.common <<< I18nL.cApi) lang
      , description: translate (I18nL.dashboard <<< I18nL.dbApiDescription) lang
      }
    ]


offerView :: State -> P.Html Action
offerView state =
    let lang' = state ^. lang in
    P.div
        [ P.className "explorer-dashboard__wrapper" ]
        [ P.div
          [ P.className "explorer-dashboard__container" ]
          [ P.h3
                [ P.className "headline"]
                [ P.text $ translate (I18nL.dashboard <<< I18nL.dbBlockchainOffer) lang' ]
          , P.div
                [ P.className "explorer-dashboard__teaser" ]
                <<< map (offerItem state) $ offerItems lang'
          ]
        ]

offerItem :: State -> OfferItem -> P.Html Action
offerItem state item =
    P.div
        [ P.className "teaser-item" ]
        [ P.h3
            [ P.className "teaser-item__headline" ]
            [ P.text item.headline ]
        , P.p
              [ P.className $ "teaser-item__description" ]
              [ P.text item.description ]
        ]


-- API

type ApiTabLabel = String

type ApiCode =
    { getAddress :: String
    , response :: String
    }

emptyApiCode :: ApiCode
emptyApiCode = { getAddress: "", response: ""}

apiCodes :: M.Map DashboardAPICode ApiCode
apiCodes =
  M.fromFoldable([
    Tuple Curl { getAddress: "Curl getAddress", response: "{\n\t\"hash\": }"}
    , Tuple Node { getAddress: "Node getAddress", response: "Node response ..."}
    , Tuple JQuery { getAddress: "jQuery getAddress", response: "jQuery response ..."}
    ])

apiView :: State -> P.Html Action
apiView state =
    P.div
        [ P.className "explorer-dashboard__wrapper" ]
        [ P.div
          [ P.className "explorer-dashboard__container" ]
          [ headerView state $ headerOptions lang'
          , P.div
            [ P.className "api-content" ]
            [ P.div
                [ P.className "api-content__container api-code"]
                [ P.div
                  [ P.className "api-code__tabs" ]
                  <<< map (apiCodeTabView state) <<< M.toAscUnfoldable $ apiTabs lang'
                , apiCodeSnippetView (translate (I18nL.dashboard <<< I18nL.dbGetAddress) lang') addressSnippet
                , apiCodeSnippetView (translate (I18nL.dashboard <<< I18nL.dbResponse) lang') responseSnippet
                ]
            , P.div
                [ P.className "api-content__container api-about"]
                [ P.h3
                    [ P.className "api-about__headline" ]
                    [ P.text $ translate (I18nL.dashboard <<< I18nL.dbAboutBlockchain) lang' ]
                , P.p
                    [ P.className "api-about__description"
                    , P.dangerouslySetInnerHTML $ translate (I18nL.dashboard <<< I18nL.dbAboutBlockchainDescription) lang' ]
                    []
                , P.div
                  [ P.className "api-about__button" ]
                  [ P.text $ translate (I18nL.dashboard <<< I18nL.dbGetApiKey) lang' ]
                ]
            ]
          ]
        ]
    where
      apiCode :: ApiCode
      apiCode = fromMaybe emptyApiCode $ M.lookup (state ^. dashboardSelectedApiCode) apiCodes
      lang' = state ^. lang
      addressSnippet = _.getAddress $ apiCode
      responseSnippet = _.response $ apiCode
      headerOptions lang = HeaderOptions
          { headline: translate (I18nL.common <<< I18nL.cApi) lang
          , link: Just $ HeaderLink { label: translate (I18nL.dashboard <<< I18nL.dbMoreExamples) lang', action: NoOp }
          }

apiTabs :: Language -> M.Map DashboardAPICode ApiTabLabel
apiTabs lang =
    M.fromFoldable(
        [ Tuple Curl $ translate (I18nL.dashboard <<< I18nL.dbCurl) lang
        , Tuple Node $ translate (I18nL.dashboard <<< I18nL.dbNode) lang
        , Tuple JQuery $ translate (I18nL.dashboard <<< I18nL.dbJQuery) lang
        ])


apiCodeTabView :: State -> Tuple DashboardAPICode ApiTabLabel -> P.Html Action
apiCodeTabView state (Tuple code label) =
    P.div
      [ P.className $ "api-code__tab " <> selectedClazz
      , P.onClick <<< const $ DashboardShowAPICode code ]
      [ P.text label ]
    where
      selectedClazz = if state ^. dashboardSelectedApiCode == code then "selected" else ""


apiCodeSnippetView :: String -> String -> P.Html Action
apiCodeSnippetView headline snippet =
    P.div
        [ P.className "api-snippet" ]
        [ P.h3
            [ P.className "api-snippet__headline" ]
            [ P.text headline ]
        , P.code
            [ P.className "api-snippet__code" ]
            [ P.text snippet ]

        ]
