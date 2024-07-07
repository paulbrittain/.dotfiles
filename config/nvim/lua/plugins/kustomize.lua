return {
  "allaman/kustomize.nvim",
  requires = "nvim-lua/plenary.nvim",
  ft = "yaml",
  opts = {
      build = {
          additional_args = {"--enable-helm", "--load-restrictor=LoadRestrictionsNone"}
      },
  },
  event = 'VeryLazy'
}
