function bins(tb, val, st, en)
  local st, en = st or 1, en or #tb
  local mid = math.floor((st + en)/2)
  if en == st then return tb[st] > val and st or st+1
  else return tb[mid] > val and bins(tb, val, st, mid) or bins(tb, val, mid+1, en)
  end
end
function isort(t)
  local ret = {t[1].y, t[2].y}
  for i = 3, #t do
    table.insert(ret, bins(ret, t[i].y), t[i].y)
  end
  return ret
end

function sort( f )
    for k = 1, #f-1 do
        local idx = k
        for i = k+1, #f do
            if f[i].y < f[idx].y then
                idx = i
            end
        end
        f[k], f[idx] = f[idx], f[k]
    end
end
