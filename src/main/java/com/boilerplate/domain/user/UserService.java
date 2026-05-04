package com.boilerplate.domain.user;

import com.boilerplate.common.exception.BusinessException;
import com.boilerplate.common.exception.ErrorCode;
import com.boilerplate.domain.user.dto.UpdateUserRequest;
import com.boilerplate.domain.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public UserResponse getUser(Long userId) {
        return UserResponse.from(findById(userId));
    }

    @Transactional
    public UserResponse updateUser(Long userId, UpdateUserRequest request) {
        User user = findById(userId);
        user.updateName(request.getName());
        return UserResponse.from(user);
    }

    public User findById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }
}
