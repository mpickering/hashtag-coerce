{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE PatternSynonyms #-}
module HashtagCoerce where

import GhcPlugins
import TcRnTypes
import HsExpr
import HsBinds
import HsExtension
import PrelNames
import ConLike

import TcRnMonad

import Generics.SYB hiding (empty)


plugin :: Plugin
plugin = defaultPlugin  {
  typeCheckResultAction = install
  , pluginRecompile = impurePlugin
  }

warnCoerce :: LHsExpr GhcTc -> TcM ()
warnCoerce (L l _) =
  setSrcSpan l $
  add_warn NoReason msg empty  --(ppr e)
  where
    msg = text "The usage of 'map' can be replaced with coerce."

install :: [CommandLineOption] -> ModSummary -> TcGblEnv -> TcM TcGblEnv
install _ _ tc_gbl = do
  let binds = tcg_binds tc_gbl
  let res = checkBinds binds
  mapM_ warnCoerce res
  return tc_gbl

checkBinds :: LHsBinds GhcTc -> [LHsExpr GhcTc]
checkBinds lhs_binds =
  listify checkCoerce lhs_binds

castExpr :: Typeable r => r -> Maybe (LHsExpr GhcTc)
castExpr = cast

checkCoerce :: Typeable r => r -> Bool
checkCoerce r =
  case castExpr r of
    Just b -> checkExpr b
    Nothing -> False

ignoreWrapper :: LHsExpr GhcTc -> HsExpr GhcTc
ignoreWrapper (L _ (HsWrap _ _ e)) = e
ignoreWrapper w = unLoc w

pattern CL :: DataCon -> LHsExpr GhcTc
pattern CL dc <- (ignoreWrapper -> HsConLikeOut _ (RealDataCon dc))

pattern MapApp :: IdP GhcTc -> DataCon -> LHsExpr GhcTc
pattern MapApp var r <- (ignoreWrapper -> (HsApp _ ((ignoreWrapper -> (HsVar _ (L _ var))))
                                                   (((CL r)))))

checkExpr :: LHsExpr GhcTc -> Bool
checkExpr (MapApp var dc)
  | (getName var) == mapName
  , isNewTyCon (dataConTyCon dc)
  = True
checkExpr _ = False
