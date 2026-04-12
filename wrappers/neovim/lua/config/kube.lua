local ok_kubectl, kubectl = pcall(require, "kubectl")
if not ok_kubectl then
  return
end

kubectl.setup({})
