<?php

return PhpCsFixer\Config::create()
    ->setRules([
        '@Symfony' => true,
        'braces'   => [
            'allow_single_line_closure'                   => true,
            'position_after_anonymous_constructs'         => 'next',
            'position_after_control_structures'           => 'next',
            'position_after_functions_and_oop_constructs' => 'next',
        ],
        'no_unneeded_curly_braces' => true,
        'array_syntax'             => [
            'syntax' => 'short',
        ],
        'list_syntax'             => [
            'syntax' => 'long',
        ],
        'declare_equal_normalize' => [
            'space' => 'single',
        ],
        'binary_operator_spaces' => [
            'align_double_arrow' => true,
        ],
        'single_quote'               => true,
        'elseif'                     => true,
        'no_empty_statement'         => true,
        'no_short_echo_tag'          => false,
        'align_multiline_comment'    => true,
        'array_indentation'          => true,
        'combine_consecutive_issets' => true,
        'combine_consecutive_unsets' => true,
        'concat_space'               => [
            'spacing' => 'one',
        ],
        'constant_case' => [
            'case' => 'lower',
        ],
        'escape_implicit_backslashes' => true,
        'lowercase_cast'              => true,
        'lowercase_keywords'          => true,
        'lowercase_static_reference'  => true,
        'method_chaining_indentation' => true,
        'class_attributes_separation' => [
            'elements' => ['method'],
        ],
        'multiline_comment_opening_closing'      => true,
        'multiline_whitespace_before_semicolons' => [
            'strategy'=> 'no_multi_line',
        ],
        'no_superfluous_elseif' => true,
        'no_superfluous_phpdoc_tags'=> [
            'allow_unused_params'=>false,
        ],
        'no_trailing_comma_in_singleline_array'=>true,
        'no_whitespace_before_comma_in_array'=>true,
        'single_class_element_per_statement'=>[
            'elements'=>['const'],
        ],
        'single_trait_insert_per_statement' => false,
        'standardize_increment'=>true,
        'increment_style'=> [
            'style'=>'post',
        ],
        'ternary_to_null_coalescing'=>true,
        'new_with_braces'=>false,
        'no_unused_imports'=>false,
    ]);
