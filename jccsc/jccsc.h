#pragma once
#ifndef JCCSC_H
#define JCCSC_H

struct JccscLexResult {
    int32 token_count;
    int32 has_using;
    int32 has_using_alias;
    int32 has_global_using;
    int32 has_namespace;
    int32 has_namespace_dotted;
    int32 has_class;
    int32 has_nested_class;
    int32 has_var;
    int32 has_generic;
    int32 has_if;
    int32 has_else;
    int32 has_switch;
    int32 has_case;
    int32 has_for;
    int32 has_while;
    int32 has_do;
    int32 has_break;
    int32 has_continue;
    int32 has_return;
    int32 has_try;
    int32 has_catch;
    int32 has_throw;
    int32 has_array;
    int32 has_multidim_array;
    int32 has_lambda;
    int32 has_ternary;
    int32 ok;
};

struct JccscAst {
    int32 using_count;
    int32 using_alias_count;
    int32 global_using_count;
    int32 namespace_count;
    int32 namespace_depth_max;
    int32 class_count;
    int32 nested_class_count;
    int32 field_count;
    int32 ctor_count;
    int32 method_count;
    int32 var_count;
    int32 var_infer_count;
    int32 generic_count;
    int32 if_count;
    int32 switch_count;
    int32 case_count;
    int32 for_count;
    int32 while_count;
    int32 do_count;
    int32 break_count;
    int32 continue_count;
    int32 return_count;
    int32 try_count;
    int32 catch_count;
    int32 throw_count;
    int32 array_count;
    int32 multidim_array_count;
    int32 lambda_count;
    int32 ternary_count;
    int32 chaining_count;
    int32 symbol_conflict_count;
};

struct JccscIr {
    int32 method_count;
    int32 field_count;
    int32 namespace_count;
    int32 using_alias_count;
    int32 nested_count;
    int32 flow_count;
    int32 exception_count;
    int32 expression_count;
    int32 generic_count;
    int32 var_infer_count;
    int32 chain_count;
    int32 modern_feature_count;
    int32 ok;
};

struct JccscCompileCache {
    int32 valid;
    int32 source_hash;
    int32 ast_hash;
    int32 ir_hash;
    int32 dep_hash;
};

struct JccscBuildStats {
    int32 cache_hit;
    int32 lex_ran;
    int32 parse_ran;
    int32 semantic_ran;
    int32 ir_ran;
    int32 backend_ran;
};

struct JccscDiagnosticEngine {
    int32 error_count;
    int32 warning_count;
    int32 info_count;
    int32 hint_count;
    int32 diagnostic_count;
    int32 verbose;
    int32 report_len;
    int32 report_cap;
    byte* report;
    int32 last_code;
    int32 last_severity;
    int32 last_phase;
    int32 last_line;
    int32 last_col;
    int32 last_start;
    int32 last_end;
};

struct JccscDebugSession {
    int32 enabled;
    int32 trace_mode;
    int32 breakpoint_phase;
    int32 breakpoint_line;
    int32 breakpoint_symbol;
    int32 paused;
    byte* trace;
    int32 trace_len;
    int32 trace_cap;
};

struct JccscLspSymbol {
    int32 name_hash;
    int32 kind;
    int32 type_code;
    int32 line;
    int32 col;
    int32 scope_depth;
};

struct JccscLspState {
    int32 initialized;
    int32 shutdown_requested;
    int32 mode;
    int32 source_hash;
    int32 ast_hash;
    int32 ir_hash;
    int32 document_version;
    int32 incremental_hits;
    int32 incremental_misses;
    int32 symbol_count;
    int32 symbol_hash_sum;
    int32 last_completion_count;
    int32 last_completion_prefix_hash;
    int32 last_diag_errors;
    int32 last_diag_warnings;
    byte* last_uri;
    int32 uri_cap;
    byte* source_cache;
    int32 source_cap;
    struct JccscCompileCache compile_cache;
    struct JccscLexResult lex;
    struct JccscAst ast;
    struct JccscIr ir;
    struct JccscDiagnosticEngine diag;
    int64 symbols_mem;
    int32 symbol_cap;
};

struct JccscTextEdit {
    int32 start;
    int32 end;
    int32 replacement_len;
    byte* replacement;
    int32 replacement_cap;
};

struct JccscWorkspaceEdit {
    int32 change_count;
    struct JccscTextEdit edit;
};

struct JccscSimFrame {
    int32 function_hash;
    int32 return_pc;
    int32 base_slot;
};

struct JccscRuntimeSimulator {
    int32 initialized;
    int32 mode;
    int32 pc;
    int32 step_count;
    int32 step_limit;
    int32 paused;
    int32 finished;
    int32 current_line;
    int32 trace_mode;
    int32 stack_size;
    int32 stack_top;
    int32 heap_count;
    int32 heap_limit;
    int32 var_count;
    int32 last_value;
    int32 last_var_hash;
    int32 breakpoint_line;
    int32 breakpoint_fn_hash;
    int32 breakpoint_ir_node;
    byte* source;
    int32 source_cap;
    byte* trace;
    int32 trace_cap;
    int32 trace_len;
    int64 frames_mem;
    int32 frames_cap;
    int64 vars_mem;
    int32 vars_cap;
};

int32 jccsc_lexer_analyze(string src, struct JccscLexResult* out);
int32 jccsc_parser_build_ast(string src, struct JccscAst* ast);
int32 jccsc_semantic_validate(string src, struct JccscAst* ast);
int32 jccsc_ir_build(struct JccscAst* ast, struct JccscIr* ir);
int32 jccsc_ir_normalize(struct JccscIr* ir);
int32 jccsc_ir_optimize(struct JccscIr* ir);
int32 jccsc_backend_translate(string src, byte* out, int32 out_cap);
int32 jccsc_backend_optimize(byte* out);
int32 jccsc_compile_to_cbang(string csharp_src, byte* out, int32 out_cap, struct JccscLexResult* lex, struct JccscAst* ast, struct JccscIr* ir);
int32 jccsc_hash_source(string src);
int32 jccsc_modern_feature_score(string src);
int32 jccsc_cache_init(struct JccscCompileCache* cache);
int32 jccsc_compile_incremental(string csharp_src, byte* out, int32 out_cap, struct JccscCompileCache* cache, struct JccscBuildStats* stats, struct JccscLexResult* lex, struct JccscAst* ast, struct JccscIr* ir);
int32 jccsc_debug_enable(struct JccscDebugSession* dbg, byte* trace, int32 cap, int32 mode);
int32 jccsc_debug_set_breakpoint(struct JccscDebugSession* dbg, int32 phase, int32 line, int32 symbol_hash);
int32 jccsc_debug_dump_ast_text(struct JccscAst* ast, byte* out, int32 cap);
int32 jccsc_debug_dump_ast_json(struct JccscAst* ast, byte* out, int32 cap);
int32 jccsc_debug_dump_ir(struct JccscIr* ir, byte* out, int32 cap);
int32 jccsc_compile_debug(string csharp_src, byte* out, int32 out_cap, struct JccscDebugSession* dbg, struct JccscLexResult* lex, struct JccscAst* ast, struct JccscIr* ir);
int32 jccsc_diag_init(struct JccscDiagnosticEngine* d, byte* report, int32 cap, int32 verbose);
int32 jccsc_diag_emit(struct JccscDiagnosticEngine* d, int32 code, int32 severity, int32 phase, int32 line, int32 col, int32 start, int32 end, string message, string suggestion);
int32 jccsc_diag_summary(struct JccscDiagnosticEngine* d);
int32 jccsc_compile_with_diagnostics(string csharp_src, byte* out, int32 out_cap, struct JccscDiagnosticEngine* diag, struct JccscLexResult* lex, struct JccscAst* ast, struct JccscIr* ir);
int32 jccsc_lsp_state_init(struct JccscLspState* st, byte* uri_buf, int32 uri_cap, byte* source_buf, int32 source_cap, byte* diag_report, int32 diag_cap);
int32 jccsc_lsp_set_mode(struct JccscLspState* st, int32 mode);
int32 jccsc_lsp_parse_content_length(string request);
int32 jccsc_lsp_handle_initialize(struct JccscLspState* st, string request, byte* out, int32 out_cap);
int32 jccsc_lsp_handle_shutdown(struct JccscLspState* st, string request, byte* out, int32 out_cap);
int32 jccsc_lsp_handle_did_open(struct JccscLspState* st, string request, byte* out, int32 out_cap);
int32 jccsc_lsp_handle_did_change(struct JccscLspState* st, string request, byte* out, int32 out_cap);
int32 jccsc_lsp_handle_did_save(struct JccscLspState* st, string request, byte* out, int32 out_cap);
int32 jccsc_lsp_completion(struct JccscLspState* st, int32 line, int32 col, byte* out, int32 out_cap);
int32 jccsc_lsp_hover(struct JccscLspState* st, int32 line, int32 col, byte* out, int32 out_cap);
int32 jccsc_lsp_document_symbols(struct JccscLspState* st, byte* out, int32 out_cap);
int32 jccsc_lsp_publish_diagnostics(struct JccscLspState* st, byte* out, int32 out_cap);
int32 jccsc_lsp_definition(struct JccscLspState* st, int32 line, int32 col, byte* out, int32 out_cap);
int32 jccsc_lsp_references(struct JccscLspState* st, int32 line, int32 col, byte* out, int32 out_cap);
int32 jccsc_lsp_signature_help(struct JccscLspState* st, int32 line, int32 col, byte* out, int32 out_cap);
int32 jccsc_lsp_dispatch_jsonrpc(struct JccscLspState* st, string request, byte* out, int32 out_cap);
int32 jccsc_refactor_build_workspace_edit(string src_before, string src_after, struct JccscWorkspaceEdit* edit);
int32 jccsc_refactor_apply_workspace_edit(string src, struct JccscWorkspaceEdit* edit, byte* out, int32 out_cap);
int32 jccsc_refactor_validate(byte* src_after, struct JccscAst* ast, struct JccscIr* ir);
int32 jccsc_refactor_rename_symbol(string src, string old_name, string new_name, byte* out, int32 out_cap, struct JccscWorkspaceEdit* edit);
int32 jccsc_refactor_extract_method(string src, string method_name, string selection_start_marker, string selection_end_marker, byte* out, int32 out_cap, struct JccscWorkspaceEdit* edit);
int32 jccsc_refactor_inline_variable(string src, string var_name, byte* out, int32 out_cap, struct JccscWorkspaceEdit* edit);
int32 jccsc_refactor_inline_function(string src, string fn_name, byte* out, int32 out_cap, struct JccscWorkspaceEdit* edit);
int32 jccsc_refactor_move_symbol(string src, string symbol_name, string target_scope, byte* out, int32 out_cap, struct JccscWorkspaceEdit* edit);
int32 jccsc_lsp_code_action(struct JccscLspState* st, byte* out, int32 out_cap);
int32 jccsc_lsp_rename(struct JccscLspState* st, string old_name, string new_name, byte* out, int32 out_cap);
int32 jccsc_lsp_workspace_edit_json(struct JccscLspState* st, struct JccscWorkspaceEdit* edit, byte* out, int32 out_cap);
int32 jccsc_sim_init(struct JccscRuntimeSimulator* sim, byte* source_buf, int32 source_cap, byte* trace_buf, int32 trace_cap, int32 step_limit, int32 heap_limit);
int32 jccsc_sim_set_mode(struct JccscRuntimeSimulator* sim, int32 mode, int32 trace_mode);
int32 jccsc_sim_load_source(struct JccscRuntimeSimulator* sim, string src, struct JccscIr* ir);
int32 jccsc_sim_set_breakpoint_line(struct JccscRuntimeSimulator* sim, int32 line);
int32 jccsc_sim_set_breakpoint_function(struct JccscRuntimeSimulator* sim, string fn_name);
int32 jccsc_sim_step_into(struct JccscRuntimeSimulator* sim);
int32 jccsc_sim_step_over(struct JccscRuntimeSimulator* sim);
int32 jccsc_sim_step_out(struct JccscRuntimeSimulator* sim);
int32 jccsc_sim_continue(struct JccscRuntimeSimulator* sim, int32 max_steps);
int32 jccsc_sim_pause(struct JccscRuntimeSimulator* sim);
int32 jccsc_sim_dump_state(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_sim_dump_stack(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_sim_dump_heap(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_lsp_debugger_start(struct JccscLspState* st, struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_lsp_debugger_step(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_lsp_debugger_continue(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_lsp_debugger_variables(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);
int32 jccsc_lsp_debugger_stack(struct JccscRuntimeSimulator* sim, byte* out, int32 out_cap);

#endif
