module KubernetesDeploy
  class DeployTaskConfigurationValidator < TaskConfigurationValidator

    private

     def run_task_specific_validations # doesn't work, where do we get the extra args?
      validate_template_dir
      validate_protected_namespaces
     end

     def validate_template_dir
      if !File.directory?(@template_dir)
        errors << "Template directory `#{@template_dir}` doesn't exist"
      elsif Dir.entries(@template_dir).none? { |file| file =~ /\.ya?ml(\.erb)?$/ }
        errors << "`#{@template_dir}` doesn't contain valid templates (postfix .yml or .yml.erb)"
      end
     end

     def validate_protected_namespaces
      if PROTECTED_NAMESPACES.include?(@namespace)
        if allow_protected_ns && prune
          errors << "Refusing to deploy to protected namespace '#{@namespace}' with pruning enabled"
        elsif allow_protected_ns
          @logger.warn("You're deploying to protected namespace #{@namespace}, which cannot be pruned.")
          @logger.warn("Existing resources can only be removed manually with kubectl. " \
            "Removing templates from the set deployed will have no effect.")
          @logger.warn("***Please do not deploy to #{@namespace} unless you really know what you are doing.***")
        else
          errors << "Refusing to deploy to protected namespace '#{@namespace}'"
        end
      end
    end
  end
end
