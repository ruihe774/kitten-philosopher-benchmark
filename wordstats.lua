local stats = {
    latin = 0,
    cjk = 0,
    in_word_state = 0,
    word_buffer = ""
}

local function is_alpha_num(char_code)
    if not char_code then return false end

    -- Digits
    if (char_code >= 0x0030 and char_code <= 0x0039) then
        return true
    end

    -- Basic Latin (A-Z, a-z)
    if (char_code >= 0x0041 and char_code <= 0x005A) or  -- A-Z
       (char_code >= 0x0061 and char_code <= 0x007A) then -- a-z
        return true
    end

    -- Latin-1 Supplement (common accented letters like é, ö, å)
    if (char_code >= 0x00C0 and char_code <= 0x00D6) or -- À-Ö
       (char_code >= 0x00D8 and char_code <= 0x00F6) or -- Ø-ö
       (char_code >= 0x00F8 and char_code <= 0x00FF) then -- ø-ÿ
        return true
    end

    -- Latin Extended-A (covers many European languages)
    if (char_code >= 0x0100 and char_code <= 0x017F) then
        return true
    end

    -- Latin Extended-B (additional characters)
    if (char_code >= 0x0180 and char_code <= 0x024F) then
        return true
    end

    -- Add more ranges if needed
    return false
end


local function is_cjk_ideograph(char_code)
    if not char_code then return false end

    -- CJK Unified Ideographs (Main Block)
    -- Range: U+4E00 to U+9FFF
    if char_code >= 0x4E00 and char_code <= 0x9FFF then return true end

    -- CJK Unified Ideographs Extension A
    if char_code >= 0x3400 and char_code <= 0x4DBF then return true end

    -- CJK Compatibility Ideographs
    if char_code >= 0xF900 and char_code <= 0xFAFF then return true end

    -- CJK Unified Ideographs Extension B
    if char_code >= 0x20000 and char_code <= 0x2A6DF then return true end

    -- CJK Symbols and Punctuation: U+3000 to U+303F
    if char_code >= 0x3000 and char_code <= 0x303F then return true end

    -- Halfwidth CJK punctuation (from Halfwidth and Fullwidth Forms block)
    if char_code >= 0xFF61 and char_code <= 0xFF64 then return true end

    -- Fullwidth ASCII variants:
    -- U+FF01 to U+FF0F (！ to ／)
    if char_code >= 0xFF01 and char_code <= 0xFF0F then return true end
    -- U+FF1A to U+FF1F (： to ？)
    if char_code >= 0xFF1A and char_code <= 0xFF1F then return true end
    -- Specific fullwidth brackets, low line, tilde
    if char_code == 0xFF3B or -- ［ FULLWIDTH LEFT SQUARE BRACKET
       char_code == 0xFF3D or -- ］ FULLWIDTH RIGHT SQUARE BRACKET
       char_code == 0xFF3F or -- ＿ FULLWIDTH LOW LINE
       char_code == 0xFF5B or -- ｛ FULLWIDTH LEFT CURLY BRACKET
       char_code == 0xFF5D or -- ｝ FULLWIDTH RIGHT CURLY BRACKET
       char_code == 0xFF5E    -- ～ FULLWIDTH TILDE
    then return true end

    -- Note: This definition focuses on ideographs. Hangul syllables (U+AC00–U+D7AF)
    -- or Japanese Hiragana/Katakana are not included here.

    return false
end

local outfile

local function get_outfile()
    if outfile ~= nil then return outfile end

    local jobname = tex.jobname
    if not jobname or jobname == "" then
        jobname = "texput"
    end
    local output_filename = jobname .. ".wordstats"

    local f, err = io.open(output_filename, "w")
    if not f then
        tex.error("Failed to open '" .. output_filename .. "': " .. tostring(err))
    end

    outfile = f
    return outfile
end

local function close_word(reason)
    if stats.in_word_state == 1 then
        stats.latin = stats.latin + 1
    end
    if stats.in_word_state ~= 0 then
        get_outfile():write(stats.word_buffer .. " ")
        -- get_outfile():write("sep: " .. reason .. "\n")
        stats.word_buffer = ""
        stats.in_word_state = 0
    end
end

local function open_cjk_word(char)
    if stats.in_word_state ~= 2 then
        close_word("transition")
        stats.in_word_state = 2
    end
    stats.cjk = stats.cjk + 1
    stats.word_buffer = stats.word_buffer .. char
end

local function open_latin_word(char)
    if stats.in_word_state ~= 1 then
        close_word("transition")
        stats.in_word_state = 1
    end
    stats.word_buffer = stats.word_buffer .. char
end

local glyph_id = node.id("glyph")
local hlist_id = node.id("hlist")
local vlist_id = node.id("vlist")
local penalty_id = node.id("penalty")
local kern_id = node.id("kern")
local disc_id = node.id("disc")
local glue_id = node.id("glue")
local rule_id = node.id("rule")
local types = node.types()
local function traverse_and_process_list(current_node)
    while current_node do
        local id = current_node.id
        if id == glyph_id then
            local char_val = current_node.char
            local char = string.utfcharacter(char_val or 0)
            if is_cjk_ideograph(char_val) then
                open_cjk_word(char)
            elseif is_alpha_num(char_val) then
                open_latin_word(char)
            else
                close_word(char)
            end
        else
            if (id == hlist_id or id == vlist_id) and current_node.head then
                traverse_and_process_list(current_node.head)
            elseif id ~= penalty_id and id ~= kern_id and id ~= disc_id and ((id ~= glue_id and id ~= rule_id) or stats.in_word_state == 1) then
                close_word(types[id])
            end
        end
        current_node = current_node.next
    end
end

local function pre_linebreak_hook(head, groupcode)
    close_word("line start")
    traverse_and_process_list(head)
    close_word("line end")
    return head
end

local function write_stats_to_file()
    local report_content = "\n" ..
        "------------------------------------------\n" ..
        "Latin words: " .. stats.latin .. "\n" ..
        "CJK ideographs: " .. stats.cjk .. "\n" ..
        "Total: " .. stats.latin + stats.cjk .. "\n" ..
        "------------------------------------------\n"

    local f = get_outfile()
    if f then
        f:write(report_content)
        f:close()
    end
end

luatexbase.add_to_callback("pre_linebreak_filter", pre_linebreak_hook, "wordstats.count_words")
luatexbase.add_to_callback("stop_run", write_stats_to_file, "wordstats.write_output")

return stats
